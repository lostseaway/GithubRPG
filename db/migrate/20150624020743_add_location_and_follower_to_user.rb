class AddLocationAndFollowerToUser < ActiveRecord::Migration
  def change
    add_column :users, :location, :text
    add_column :users, :follower, :integer
  end
end
