require 'threadpool'
class Commit < ActiveRecord::Base
	@pool = ThreadPool.new(15)	
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

	def self.Ncommand(cmd)
		puts cmd
		return `#{cmd}`
	end

	def self.getJSON(url)
		cmd = "curl -sS -u lostseaway:64120430d86ac36403ab55a826b49a5b3893e7c5 "
		cmd += url
		# data = command(cmd)
		data = Ncommand(cmd)
		return JSON.parse(data)
	end

	def self.getTag(url)
		cmd = "curl -I -sS -u lostseaway:64120430d86ac36403ab55a826b49a5b3893e7c5 "
		cmd += url
		data = command(cmd)
		tag = data.split("\n").select{|x| x.include?("ETag:")}
		if tag[0]== nil
			return ""
		end
		return tag[0].split(":")[1].chomp.gsub("\"","").gsub(" ","")
	end

	def self.loadSingleCommit(commit,full_name,user_id)
		if commit.class.to_s=="Array"
			return 
		end
		sha = commit["sha"]
		check = Commit.find_by(sha: sha)
		if check != nil
			return
		end

		
		com = {}
		com["user_id"] = user_id
		com["sha"] = sha
		com["before"] = commit["parents"] == [] ? "" : commit["parents"][0]["sha"]
		com["message"] = commit["commit"]["message"].encode("UTF-8")
		com["commited_at"] = DateTime.strptime(commit["commit"]["author"]["date"], '%Y-%m-%dT%H:%M:%SZ')

		added = 0
		changed = 0
		delete = 0
		puts ">>>BEFORE<<<<"
		json = getJSON("https://api.github.com/repos/"+full_name+"/compare/"+com["before"]+"..."+sha)
		puts ">>>AFTER<<<<"
		if json.has_key?("message")
			return
		end
		puts "after"
		json["files"].each{|y| 
			added += y["additions"]
			changed += y["changes"]
			delete += y["deletions"]
		}
		com["additions"] = added
		com["modify"] = changed
		com["deletions"] = delete
		Commit.create(com)
		return 
	end
	
	def self.loadAllCommits(user_id)
		user = User.find(user_id)
		repos = UserRepository.where(user_id: user_id)
		repos.each{|repo|
			repo_full = Repository.find(repo.repository_id)
			tag = getTag("https://api.github.com/repos/"+repo_full.full_name+"/commits?author="+user.login)
			if tag != repo_full.match 
				commits = getJSON("https://api.github.com/repos/"+repo_full.full_name+"/commits?author="+user.login)
				commits.each{|commit| 
					@pool.process{ loadSingleCommit(commit,repo_full.full_name,user_id)}
					# loadSingleCommit(commit,repo_full.full_name,user_id)
				}
			end
		}
		backlog = @pool.backlog
		while @pool.backlog !=0
			if backlog != backlog
				puts "HAVE #{@pool.backlog} LEFT"
				backlog = @pool.backlog
			end
		end

	end


	def self.getNumberByDay(user_id)
		gbyd = {}
		commits = Commit.where(user_id: user_id).map{|x| x.commited_at.strftime("%d")}
		(1..31).to_a.each{|x| 
			if x < 10
				gbyd["0"+x.to_s] = commits.count{|y| y == "0"+x.to_s}
			else
				gbyd[x.to_s] = commits.count{|y| y == x.to_s}
			end
		}
		# p gbyd.to_a
		return gbyd.to_a
	end

	def self.getNumberByHr(user_id)
		gbyhr = {}
		commits = Commit.where(user_id: user_id).map{|x| x.commited_at.strftime("%H")}
		(0..23).to_a.each{|x| 
			if x < 10
				gbyhr["0"+x.to_s] = commits.count{|y| y == "0"+x.to_s}
			else
				gbyhr[x.to_s] = commits.count{|y| y == x.to_s}
			end

		}
		# p gbyhr.to_a
		return gbyhr.to_a
	end

	def self.getNumberByDFW(user_id)
		gbydfw = {}
		commits = Commit.where(user_id: user_id).map{|x| x.commited_at.strftime("%a")}
		day = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
		day.to_a.each{|x| 
				gbydfw[x] = commits.count{|y| y == x}
		}
		# p gbydfw.to_a
		return gbydfw.to_a
	end	

	def self.getNumberModify(user_id)
		commits = Commit.where(user_id: user_id)
		line = {}
		line["added"] = 0
		line["modify"] = 0
		line["delete"] = 0
		commits.each{|x|
			line["added"] += x.additions
			line["modify"] += x.modify
			line["delete"] += x.deletions
		}
		return line
	end
end
