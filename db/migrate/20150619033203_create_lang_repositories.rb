class CreateLangRepositories < ActiveRecord::Migration
  def change
    create_table :lang_repositories do |t|
      t.float :byte
      t.string :match

      t.timestamps null: false
    end
  end
end
