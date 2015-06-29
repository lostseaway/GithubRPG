class ChangeMsgDatatypeInEvents < ActiveRecord::Migration
  def change
  	change_column :events, :message, :text
  end
end
