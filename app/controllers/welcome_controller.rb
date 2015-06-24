class WelcomeController < ApplicationController
  def index
  	users = IO.readlines("#{Rails.root}/app/assets/data/users.txt")
  	@show_users = (users.shuffle)[0..9]

  end
end
