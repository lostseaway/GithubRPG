class AddTotalAndRemoveModitryToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :total, :integer
    remove_column :commits, :before
  	remove_column :commits, :head
  	remove_column :commits, :modify
  end
end
