class AddRepoIdToCommits < ActiveRecord::Migration
  def change
  	add_column :commits, :repository_id, :integer

    add_foreign_key :commits, :repositories
  end
end
