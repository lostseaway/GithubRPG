class SearchController < ApplicationController
	skip_before_filter  :verify_authenticity_token
	def index
		render 'index'
	end

	def sort_it(array,*keys)
	  array.map { |h| 
	  	[h["langs"].values_at(*keys), h] 
	  	p h 
	  	}.sort_by(&:first).map(&:last)
	end  
	#POST /lookup
	def lookup	
		# p request
		json = JSON.parse(request.body.read)
		p json
		lang = []
		ot = []
		json.each{|opt|
			p opt["option"]
			if opt["option"] == "Languages"
				sql  = 'SELECT users.name ,users.login, langs.lang , SUM(commit_files.change),users.location  AS LOC FROM users RIGHT JOIN commits ON users.id = commits.user_id RIGHT JOIN commit_files ON commits.id = commit_files.commit_id INNER JOIN file_types ON commit_files.file_type_id = file_types.id INNER JOIN langs ON file_types.lang_id = langs.id GROUP BY langs.lang , users.name'
				commits = ActiveRecord::Base.connection.execute(sql).to_a
				
				commits.each{|x|
					# p lang
					if lang.length == 0
						tmp = {}
						tmp["user"] = x[0]
						tmp["login"] = x[1]
						tmp["Location"] = x[4]
						t = {}
						t[x[2]] = x[3]
						tmp["langs"] = t
						lang << tmp
					else
						l = lang.select{|y| y["user"] == x[0]}
						if l.length != 0
							l[0]["langs"][x[2]] = x[3]

							
						else
							# lang.length == 0
							tmp = {}
							tmp["user"] = x[0]
							tmp["login"] = x[1]
							tmp["Location"] = x[4]
							t = {}
							t[x[2]] = x[3]
							tmp["langs"] = t
							lang << tmp
						end
					end
				}
				# puts "ssss"
				# p lang
				

				opt["value"].each{|x|
					p x
					lang = lang.select{|k| k["langs"].has_key? x }
				}

				if lang.length == 0
					p "in"
					render nothing: true, status: :not_found
					return 
				end
				
				# lang.each{|x|
				# 	puts "User : "+x["user"]
				# 	x["langs"].each{|y|
				# 		y = y.to_a

				# 		puts ">>> "+y[0]+" : "+y[1].to_s
				# 	}
				# }
				# puts "SORT!"
				lang = lang.sort_by{|x| -x["langs"][opt["value"][0]]}

				# lang.each{|x|
				# 	puts "User : "+x["user"]+" : "+x["login"]
				# 	x["langs"].each{|y|
				# 		y = y.to_a

				# 		puts ">>> "+y[0]+" : "+y[1].to_s
				# 	}
				# }
			else
				if ot == []
					sql  = 'SELECT users.login , users.name ,users.location , users.follower, YEAR(NOW()) - YEAR(users.created_at) AS exp  FROM users'
					ot = ActiveRecord::Base.connection.execute(sql).to_a
				end

				p ot
				if opt["option"] == "Follower"
					ot = ot.select{|x| x[3] >= opt["value"].to_i}
				elsif opt["option"] == "Experience"
					ot = ot.select{|x| x[4] >= opt["value"].to_i}
				elsif opt["option"] == "Location"
					ot = ot.select{|x| x[2] == opt["value"]}
				end
					

				if ot.length == 0
					render nothing: true, status: :not_found
					return 
				end

				p ot
			end
		}

		out = []
		if ot == []
			out = lang
		else
			k = []
			ot.each{|x|
				tmp = {}
				tmp["login"] = x[0]
				tmp["user"] = x[1]
				tmp["Location"] = x[2]
				tmp["Follower"] = x[3]
				tmp["Experience"] = x[4]
				k << tmp
			}

			if lang == []
				out = k
			else
				lang.each{|x|
					p ["x",x]
					p ["k",k]
					t = k.select{|y| y["login"] == x["login"]}
					if t.length == 0
						next
					end
					tmp = t[0]
					x["Location"] = tmp["Location"]
					x["Follower"] = tmp["Follower"]
					x["Experience"] = tmp["Experience"]

					out << x
				}
			end

		end
		p out

		if out.length == 0
			render nothing: true, status: :not_found
			return 		
		end
		render json: out, status: :ok
	end
end
