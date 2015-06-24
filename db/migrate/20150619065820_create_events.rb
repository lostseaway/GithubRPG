class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :event_id
      t.string :event_type
      t.string :message

      t.timestamps null: false
    end
  end
end
