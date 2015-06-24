class AddForeignKeyToUserRepository < ActiveRecord::Migration
  def change
    add_column :user_repositories, :user_id, :integer
    add_column :user_repositories, :repository_id, :integer

    add_foreign_key :user_repositories, :users
    add_foreign_key :user_repositories, :repositories
  end
end
