class CreateLangs < ActiveRecord::Migration
  def change
    create_table :langs do |t|
      t.string :lang

      t.timestamps null: false
    end
  end
end
