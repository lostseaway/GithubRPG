class AddRepoTagToUser < ActiveRecord::Migration
  def change
    add_column :users, :repo_tag, :string
  end
end
