class AddLastModifyToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_modify, :date
  end
end
