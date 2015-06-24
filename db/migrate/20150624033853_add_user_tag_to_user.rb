class AddUserTagToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_tag, :string
  end
end
