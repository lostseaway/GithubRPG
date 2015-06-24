class Repository < ActiveRecord::Base
	
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

	def self.loadRepo(full_name)
		repo = getJSON("https://api.github.com/repos/"+full_name)
		if repo.has_key?("message")
			return nil
		end
		n_repo = create(name: repo["name"].encode("UTF-8") , full_name: repo["full_name"] , description: repo["description"] , created_at: repo["created_at"])
		return n_repo
	end

	def self.getRepo(repo)
		n_repo = self.find_by(full_name: repo["full_name"])
		if n_repo == nil
			n_repo = create(name: repo["name"] , full_name: repo["full_name"] , description: repo["description"] , created_at: repo["created_at"])
		end
		return n_repo
	end

end
