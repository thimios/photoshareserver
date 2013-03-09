class AddDisplayTitleToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :display_title, :string
  end
end
