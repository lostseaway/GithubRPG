class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.string :sha
      t.string :before
      t.string :head
      t.string :message
      t.integer :additions
      t.integer :modify
      t.integer :deletions
      t.datetime :commited_at

      t.timestamps null: false
    end
  end
end
