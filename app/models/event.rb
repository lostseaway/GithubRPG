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

	def self.loadSingleEvent(x,user)
		if !x["public"] 
			return true
		end
		if x["id"] == user.last_modify
			return false
		end
		puts "IN"
		if Event.find_by(event_id: x["id"]) != nil
			return true
		end
		line = {}
		line["event_id"] = x["id"]
		line["user_id"] = user.id
		repo = Repository.find_by(full_name: x["repo"]["name"])
		if repo == nil
			repo = Repository.loadRepo(x["repo"]["name"])
			if repo == nil
				return true
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
				commit["sha"] = y["sha"]
				commit["commit"] = {}
				commit["commit"]["author"] = {}
				commit["commit"]["author"]["date"] = x["created_at"]
				commit["commit"]["message"] = y["message"]

				Commit.loadSingleCommit(commit,repo.full_name,user.id,repo.id)
			}
		end
		create(line)
		return true
	end

	def self.loadAllEvent(user_id)
		user = User.find(user_id)
		json_user = getJSON("https://api.github.com/users/"+user.login+"/events")
		json_user[0..5].each{|x|
			# @pool.process{
				loadSingleEvent(x,user)
			# }

		}
		backlog = @pool.backlog
		puts "Wait at event #{backlog}"
		while @pool.backlog !=0
			if backlog != backlog
				puts "HAVE #{@pool.backlog} LEFT"
				backlog = @pool.backlog
			end
		end


		tag = getTag("https://api.github.com/users/"+user.login+"/events")
		user.update_attributes(last_modify:json_user[0]["id"],match:tag)
		user.save
	end

	def self.updateEvent(user_id)
		user = User.find(user_id)
		json_user = getJSON("https://api.github.com/users/"+user.login+"/events")
		json_user.each{|x|
			# @pool.process{
				if !loadSingleEvent(x,user)
					break
				end
			# }

		}
		backlog = @pool.backlog
		p backlog
		while @pool.backlog !=0
			if backlog != backlog
				puts "HAVE #{@pool.backlog} LEFT"
				backlog = @pool.backlog
			end
		end


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
				updateEvent(user_id)
				event = Event.where(user_id: user.id).order('created_at DESC')
				return event
			end
		end
	end
end
