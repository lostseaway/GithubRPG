class ModifyColInCommits < ActiveRecord::Migration
  def change
  	# remove_column :commits, :before
  	# remove_column :commits, :head
  	# remove_column :commits, :modify

  	# add_column :commits, :total, :integer

  	# add_column :commits, :repository_id, :integer

    # add_foreign_key :commits, :repositories
  end
end
