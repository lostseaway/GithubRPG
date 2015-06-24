class ChangeFormatInUser < ActiveRecord::Migration
  def change
  	change_column :users, :last_modify, :string
  end
end
