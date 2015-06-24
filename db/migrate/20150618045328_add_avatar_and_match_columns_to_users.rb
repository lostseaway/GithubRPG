class AddAvatarAndMatchColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_url, :string
    add_column :users, :match, :string
  end
end
