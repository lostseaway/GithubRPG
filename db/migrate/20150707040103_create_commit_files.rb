class CreateCommitFiles < ActiveRecord::Migration
  def change
    create_table :commit_files do |t|
      t.integer :commit_id
      t.integer :file_type_id
      t.integer :additions
      t.integer :deletions
      t.integer :change

      t.timestamps null: false
    end

    add_foreign_key :commit_files, :commits
    add_foreign_key :commit_files, :file_types
  end
end
