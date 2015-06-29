require 'json'
require 'net/http'
require 'open3'
require 'Date'
class UserController < ApplicationController
	skip_before_action :verify_authenticity_token
	def command(cmd)
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

	def getJSON(url)
		cmd = "curl -sS -u lostseaway:64120430d86ac36403ab55a826b49a5b3893e7c5 "
		cmd += url
		data = command(cmd)
		return JSON.parse(data)
	end


	def getuser
		id = params[:id]
		puts "LOADING USER DATA..."
		@user = User.getUser(id)
		puts "DONE!"
		puts "LOADING USER REPO..."
		@repo = UserRepository.getUserRepo(@user.id)
		puts "DONE!"
		puts "LOADING USER LANG..."
		@lang = LangRepository.getLangRepo(@user.id)
		# @lang = {}
		puts "DONE!"
		puts "LOADING USER EVENT..."

		@event = Event.getEvent(@user.id)
		puts "DONE!"
		puts "LOADING USER Commits..."
		# @commits = getTL(id)
		# p @commits[0]
		puts "DONE!"
		@gbyd = Commit.getNumberByDay(@user.id)
		@gbyhr = Commit.getNumberByHr(@user.id)
		@gbydfw = Commit.getNumberByDFW(@user.id)
		@modifyNo = Commit.getNumberModify(@user.id)

		render 'index'
	end

	def loading
		@id = params[:id]
		render 'loading'
	end


end
