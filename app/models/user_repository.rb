require 'json'
require 'net/http'
require 'open3'
require 'Date'

class UserRepository < ActiveRecord::Base
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
		tag = data.split("\n").select{|x| x.include?("ETag:")}
		if tag[0]== nil
			return ""
		end
		return tag[0].split(":")[1].chomp.gsub("\"","").gsub(" ","")
	end

	def self.load(user_id)
		login = User.find(user_id).login
		tmp = getJSON("https://api.github.com/users/"+login+"/repos?type=all")

		tmp.each{|x|
			if x["fork"]
				next
			end
			repo = Repository.getRepo(x)
			if x["owner"]["login"]==login
				status = "owner"
			else
				status = "member"
			end
			create(user_id: user_id,repository_id: repo.id,status: status)
		}

	end

	def self.update(user)
		json = getJSON("https://api.github.com/users/"+user.login+"/repos?type=all")
		json = json.sort_by{|x| DateTime.strptime(x["created_at"], '%Y-%m-%dT%H:%M:%SZ')}
		for x in 1..json.length-2
			tmp = json[-x]
			check = Repository.find_by(full_name: tmp["full_name"])
			if  check != nil
				if find_by(repository_id: check.id) != nil
					break
				end
			end
			repo = Repository.getRepo(tmp)
			if tmp["owner"]["login"]==user.login
				status = "owner"
			else
				status = "member"
			end
			create(user_id: user.id,repository_id: repo.id,status: status)
		end
	end

	def self.getQ(user_id)
		sql = "SELECT repositories.name , repositories.description , user_repositories.status,repositories.full_name FROM user_repositories LEFT JOIN repositories ON user_repositories.repository_id = repositories.id WHERE user_repositories.user_id = "+user_id.to_s+" ORDER BY repositories.created_at DESC"
		repo = ActiveRecord::Base.connection.execute(sql).to_a

		return repo
	end

	def self.getUserRepoL(user_id)
		repo = self.where(user_id: user_id)
		user = User.find(user_id)
		tag = getTag("https://api.github.com/users/"+user.login+"/repos?type=all")
		if repo.length == 0
			self.load(user_id)
			repo = self.where(user_id: user_id)
		elsif user.repo_tag != tag
			user.update_attributes(repo_tag:tag)
			update(user)
			repo = self.where(user_id: user_id)
		end

		return repo
	end


	def self.getUserRepo(user_id)
		repo = getQ(user_id)
		user = User.find(user_id)
		getQ(user_id)
		tag = getTag("https://api.github.com/users/"+user.login+"/repos?type=all")
		if repo.length == 0
			self.load(user_id)
			repo = getQ(user_id)
		elsif user.repo_tag != tag
			user.update_attributes(repo_tag:tag)
			update(user)
			repo = getQ(user_id)
		end

		return repo
	end
end
