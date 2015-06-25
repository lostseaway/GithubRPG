require 'threadpool'
class Event < ActiveRecord::Base
	@pool = ThreadPool.new(7)
	def self.command(cmd)
		out = []
		Open3.popen2e(cmd) do |stdin, stdout_err, wait_thr|
		  while line = stdout_err.gets
		    out << line
		  end

		  exit_status = wait_thr.value
		  unless exit_status.success?
		    abort "FAILED !!! #{cmd}"
		  end
		end
		# return (["["]+out[3..-1]).join("||")
		return out.join("")
	end

	def self.getJSON(url)
		cmd = "curl -sS -u lostseaway:64120430d86ac36403ab55a826b49a5b3893e7c5 "
		cmd += url
		data = command(cmd)
		return JSON.parse(data)
	end

	def self.getTag(url)
		cmd = "curl -I -sS -u lostseaway:64120430d86ac36403ab55a826b49a5b3893e7c5 "
		cmd += url
		data = command(cmd)
		return data.split("\n").select{|x| x.include?("ETag:")}[0].split(":")[1].chomp.gsub("\"","").gsub(" ","")
	end

	def self.loadAllEvent(user_id)
		user = User.find(user_id)
		json_user = getJSON("https://api.github.com/users/"+user.login+"/events")
		json_user.each{|x|
			@pool.process{
				if !x["public"] 
					next
				end
				if x["id"] == user.last_modify
					break
				end

				if Event.find_by(event_id: x["id"]) != nil
					next
				end
				line = {}
				line["event_id"] = x["id"]
				line["user_id"] = user.id
				repo = Repository.find_by(full_name: x["repo"]["name"])
				if repo == nil
					repo = Repository.loadRepo(x["repo"]["name"])
					if repo == nil
						next
					end
				end
				line["repository_id"] = repo.id
				line["event_type"] = x["type"]
				line["message"] = ""
				line["created_at"] = x["created_at"]

				if line["event_type"] == "PushEvent"
					payload = x["payload"]

					line["message"] = payload["commits"][0]["message"]
					payload["commits"].each{|y|
						commit ={}
						commit["user_id"] = user.id
						commit["head"] = payload["head"]
						commit["before"] = payload["before"]
						commit["message"] = y["message"].encode("UTF-8")
						commit["sha"] = y["sha"]
						commit["commited_at"] = DateTime.strptime(line["created_at"], '%Y-%m-%dT%H:%M:%SZ')

						added = 0
						changed = 0
						delete = 0
						json = getJSON("https://api.github.com/repos/"+repo.full_name+"/compare/"+commit["before"]+"..."+y["sha"])
						if json.has_key?("message")
							next
						end

						json["files"].each{|y| 
							added += y["additions"]
							changed += y["changes"]
							delete += y["deletions"]
						}
						commit["additions"] = added
						commit["modify"] = changed
						commit["deletions"] = delete
						Commit.create(commit)
					}
				end
				create(line)
			}

		}

		tag = getTag("https://api.github.com/users/"+user.login+"/events")
		user.update_attributes(last_modify:json_user[0]["id"],match:tag)
		user.save
	end

	def self.getEvent(user_id)
		user = User.find(user_id)	
		if user.match == nil
			loadAllEvent(user_id)
			Commit.loadAllCommits(user_id)
			event = Event.where(user_id: user.id).order('created_at DESC')
			return event
		else
			tag = getTag("https://api.github.com/users/"+user.login+"/events")
			if tag == user.match
				event = Event.where(user_id: user.id).order('created_at DESC')
				return event
			else
				loadAllEvent(user_id)
				event = Event.where(user_id: user.id).order('created_at DESC')
				return event
			end
		end
	end
end
