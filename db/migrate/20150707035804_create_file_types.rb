class CreateFileTypes < ActiveRecord::Migration
  def change
    create_table :file_types do |t|
      t.string :name
      t.integer :lang_id

      t.timestamps null: false
    end

    add_foreign_key :file_types, :langs
  end
end
