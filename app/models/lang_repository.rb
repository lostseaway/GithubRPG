class LangRepository < ActiveRecord::Base
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

	def self.loadLang(repo_id)
		full_name = Repository.find(repo_id).full_name
		json = getJSON("https://api.github.com/repos/"+full_name+"/languages")

		json.each{|x|
			lang = Lang.find_by(lang: x[0])
			if lang == nil
				lang = Lang.create(lang: x[0])
			end

			self.create(byte: x[1],lang_id: lang.id,repository_id: repo_id)
		}
	end

	def self.getLangRepo(user_id)
		# lang = self.where(repository_id: repo_id)
		# if lang.length == 0
		# 	loadLang(repo_id)
		# 	lang = self.where(repository_id: repo_id)
		# end
		# return lang
		sql = "SELECT SUM(byte) , lang_repositories.lang_id FROM user_repositories RIGHT JOIN lang_repositories ON user_repositories.repository_id = lang_repositories.repository_id WHERE user_repositories.user_id = "+user_id.to_s+" AND user_repositories.status = \"owner\" GROUP BY lang_repositories.lang_id"
		lang = ActiveRecord::Base.connection.execute(sql).to_a
		if lang.length == 0
			repos = UserRepository.getUserRepoL(user_id)
			repos.each{|x| loadLang(x.repository_id)}
			sql = "SELECT SUM(byte) , lang_repositories.lang_id FROM user_repositories RIGHT JOIN lang_repositories ON user_repositories.repository_id = lang_repositories.repository_id WHERE user_repositories.user_id = "+user_id.to_s+" AND user_repositories.status = \"owner\" GROUP BY lang_repositories.lang_id"
			lang = ActiveRecord::Base.connection.execute(sql).to_a	
		end
		return lang


	end

end
