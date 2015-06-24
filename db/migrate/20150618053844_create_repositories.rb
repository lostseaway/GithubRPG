class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :name
      t.string :full_name
      t.string :description
      t.string :match

      t.timestamps null: false
    end
  end
end
