require 'json'
require 'net/http'
require 'open3'
require 'Date'

class User < ActiveRecord::Base
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

	def self.update(login,tag)
		json_user = getJSON("https://api.github.com/users/"+login)
		user = User.find_by(login: login)
		location = json_user["location"] == "" ? "UNKNOWN" : json_user["location"]
		user.update_attributes(name: json_user["name"],login: json_user["login"],email: json_user["email"], avatar_url: json_user["avatar_url"] , created_at: json_user["created_at"], user_tag: tag ,location: location , follower:json_user["followers"])

	end

	def self.loadUser(login)
		json_user = getJSON("https://api.github.com/users/"+login)
		tag = getTag("https://api.github.com/users/"+login)
		location = json_user["location"] == "" ? "UNKNOWN" : json_user["location"]
		user = create(name: json_user["name"],login: json_user["login"],email: json_user["email"], avatar_url: json_user["avatar_url"] , created_at: json_user["created_at"], user_tag: tag ,location: location,follower:json_user["followers"])

		return user
	end

	def self.getUser(login)
		user = User.find_by(login: login)
		p user
		if user == nil
			puts "NEW USER"
			user = loadUser(login)
		else
			tag = getTag("https://api.github.com/users/"+login)
			if user.user_tag == nil
				update(login,tag)
			elsif tag != user.user_tag
				update(login,tag)
			end
			user = User.find_by(login: login)
		end

		return user
	end
end
