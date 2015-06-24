class AddForeignKeyToLangRepository < ActiveRecord::Migration
  def change
    add_column :lang_repositories, :lang_id, :integer
    add_column :lang_repositories, :repository_id, :integer

    add_foreign_key :lang_repositories, :langs
    add_foreign_key :lang_repositories, :repositories
  end
end
