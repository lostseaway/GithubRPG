class CreateUserRepositories < ActiveRecord::Migration
  def change
    create_table :user_repositories do |t|
      t.string :status
      t.timestamps null: false
    end

  end
end
