class AddCheckToFileType < ActiveRecord::Migration
  def change
    add_column :file_types, :check, :boolean
  end
end
