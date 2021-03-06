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


	def createDayGraph(commits)
		gbyd = {}
		(1..31).to_a.each{|x| 
			if x < 10
				gbyd["0"+x.to_s] = commits.count{|y| y["day"] == "0"+x.to_s}
			else
				gbyd[x.to_s] = commits.count{|y| y["day"] == x.to_s}
			end

		}
		# p gbyd.to_a
		return gbyd.to_a
	end

	def createHrGraph(commits)
		gbyhr = {}
		(0..23).to_a.each{|x| 
			if x < 10
				gbyhr["0"+x.to_s] = commits.count{|y| y["hr"] == "0"+x.to_s}
			else
				gbyhr[x.to_s] = commits.count{|y| y["hr"] == x.to_s}
			end

		}
		# p gbyhr.to_a
		return gbyhr.to_a
	end

	
	def createDFWGraph(commits)
		gbydfw = {}
		day = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
		day.to_a.each{|x| 
				gbydfw[x] = commits.count{|y| y["dfw"] == x}
		}
		# p gbydfw.to_a
		return gbydfw.to_a
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
		@gbyd = Commit.getGraph(@user.id,(1..31).to_a.map{|x| x < 10 ? "0"+x.to_s : x.to_s},"%d")
		@gbyhr = Commit.getGraph(@user.id,(1..24).to_a.map{|x| x < 10 ? "0"+x.to_s : x.to_s},"%H")
		@gbydfw = Commit.getGraph(@user.id,["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"%a")
		# @modifyNo = {}
		@modifyNo = Commit.getNumberModify(@user.id)
		@graph = Commit.getGraphN(@user.id.to_s)
		p @graph
		render 'index'
	end

	def loading
		@id = params[:id]
		render 'loading'
	end

	def testGraph
		render 'graph'
	end


end
