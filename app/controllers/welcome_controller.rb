class WelcomeController < ApplicationController
  def index
  	users = IO.readlines("#{Rails.root}/app/assets/data/users.txt")
  	@show_users = (users.shuffle)[0..9]
  	@user_country = getCountry
  	@number_user = getAllUser.length
  	@number_repo = getRepoNumber
  	@project_lang = getProjectLang
  	render 'index'
  end

  def getCountry
		sql = "SELECT COUNT(location) AS Number, location FROM users WHERE location <> \"UNKNOWN\" GROUP BY location ORDER BY Number DESC"
		return ActiveRecord::Base.connection.execute(sql).to_a
  end

  def getAllUser
  	sql = "SELECT * FROM users"
	return ActiveRecord::Base.connection.execute(sql).to_a
  end

	def getRepoNumber
  		sql = "SELECT * FROM repositories"
		return ActiveRecord::Base.connection.execute(sql).to_a.length
	end

	def getProjectLang
		# sql ="SELECT COUNT(langs.lang) as Project , langs.lang FROM lang_repositories LEFT JOIN langs ON lang_repositories.lang_id = langs.id GROUP BY langs.lang ORDER BY Project DESC"
    sql = "SELECT langs.lang FROM `file_types` LEFT JOIN langs ON file_types.lang_id = langs.id WHERE file_types.check = 1 ORDER BY `name` ASC"
		return ActiveRecord::Base.connection.execute(sql).to_a
	end		

end
