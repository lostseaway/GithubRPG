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

	def self.loadSingleCommit(commit,full_name,user_id,repo_id)
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

		com["message"] = commit["commit"]["message"].encode("UTF-8")
		com["commited_at"] = DateTime.strptime(commit["commit"]["author"]["date"], '%Y-%m-%dT%H:%M:%SZ')

		json = getJSON("https://api.github.com/repos/"+full_name+"/commits/"+sha)
		if json.has_key?("message")
			return
		end

		com["total"] = json["stats"]["total"]

		com["repository_id"] = repo_id
		com["additions"] = json["stats"]["additions"]
		com["deletions"] = json["stats"]["deletions"]
		ncom = Commit.create(com)
		commitfile = []
		files = json["files"]
		files.each{|file|
			ft = file["filename"].split(".")
			if ft.length <= 1
				next
			end
			ft = ft[-1]
			puts 'File : #{file["filename"]} File Type : #{ft}'

			if commitfile.length == 0
				nt = {}
				nt["commit_id"] = ncom.id
				nt["file_type_id"] = ft
				nt["additions"] = file["additions"]
				nt["deletions"] = file["deletions"]
				nt["change"] = file["changes"]
				commitfile << nt
			else
				st = commitfile.select{|x| x["file_type_id"]==ft}
				if st.length == 0
					nt = {}
					nt["commit_id"] = ncom.id
					nt["file_type_id"] = ft
					nt["additions"] = file["additions"]
					nt["deletions"] = file["deletions"]
					nt["change"] = file["changes"]
					commitfile << nt
				else
					st[0]["additions"] = file["additions"]
					st[0]["deletions"] = file["deletions"]
					st[0]["change"] = file["changes"]
				end
			end
		}
		commitfile.each{|x| CommitFile.addFile(ncom.id,x)}

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
					@pool.process{ 
						loadSingleCommit(commit,repo_full.full_name,user_id,repo_full.id)
					}
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

	def self.getGraph(user_id,arr,param)
		out = []
		commits = Commit.where(user_id: user_id).map{|x| [x.commited_at.strftime(param),x.additions,x.deletions,x.total]}
		arr.each{|x| 
			commit = commits.select{|y| y[0] == x.to_s}
			line = {}
			line["n"] = x.to_s
			line["count"] = commit.length
			if commit.length == 0
				line["additions"] = 0
				line["deletions"] = 0
				line["total"] = 0

			else
				line["additions"] = commit.map{|x| x[1]}.inject(:+)
				line["deletions"] = commit.map{|x| x[2]}.inject(:+)
				line["total"] =  commit.map{|x| x[3]}.inject(:+)
			end
			out << line

		}
		# p out.to_a
		return out
	end
	

	def self.getNumberModify(user_id)
		commits = Commit.where(user_id: user_id)
		line = {}
		line["added"] = 0
		line["delete"] = 0
		commits.each{|x|
			line["added"] += x.additions
			line["delete"] += x.deletions
		}
		return line
	end

	def self.getNewGraph(user_id)
		# sql = 'SELECT commit_files.change , langs.lang , DATE_FORMAT(DATE(commits.commited_at),"%Y-%m") as ct FROM commit_files LEFT JOIN commits ON commit_files.commit_id = commits.id LEFT JOIN file_types on commit_files.file_type_id = file_types.id Left JOIN langs ON file_types.lang_id = langs.id WHERE file_types.check = 1 AND commits.user_id = '+user_id+' GROUP BY ct , langs.lang
# ORDER BY langs.lang ASC , ct ASC'
sql = 'SELECT commit_files.change , langs.lang , DATE_FORMAT(DATE(commits.commited_at),"%Y-%m") as ct FROM commit_files LEFT JOIN commits ON commit_files.commit_id = commits.id LEFT JOIN file_types on commit_files.file_type_id = file_types.id Left JOIN langs ON file_types.lang_id = langs.id WHERE file_types.check = 1 AND commits.user_id = '+user_id+' GROUP BY ct , langs.lang
ORDER BY ct ASC'
		commits = ActiveRecord::Base.connection.execute(sql).to_a

		out = []
		commits.each{|commit|
			if commit[0] == 0
				next
			end
			if out.length == 0
				tmp = {}
				tmp["key"] = commit[1]
				tmp["value"] = []
				tmp["value"] << [(DateTime.strptime(commit[2],'%Y-%m').strftime("%s")+"000").to_i,commit[0]]
				out << tmp
			else
				c = out.select{|x| x["key"]==commit[1]}
				if c.length == 0
					tmp = {}
					tmp["key"] = commit[1]
					tmp["value"] = []
					tmp["value"] << [(DateTime.strptime(commit[2],'%Y-%m').strftime("%s")+"000").to_i,commit[0]]
					out << tmp
				else
					c[0]["value"] << [(DateTime.strptime(commit[2],'%Y-%m').strftime("%s")+"000").to_i,commit[0]]
				end
			end
		}
		return out
	end
end
