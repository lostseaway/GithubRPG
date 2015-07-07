class AddMajorLangToRepository < ActiveRecord::Migration
  def change
  	add_column :repositories, :lang_id, :integer

    add_foreign_key :repositories, :langs
  end
end
