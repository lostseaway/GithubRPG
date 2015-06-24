class AddForeignKeyToEvent < ActiveRecord::Migration
  def change
    add_column :events, :user_id, :integer
    add_column :events, :repository_id, :integer

    add_foreign_key :events, :users
    add_foreign_key :events, :repositories
  end
end
