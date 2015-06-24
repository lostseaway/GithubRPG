class AddForeignKeyToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :user_id, :integer

    add_foreign_key :commits, :users
  end
end
