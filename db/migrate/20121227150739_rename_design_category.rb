class RenameDesignCategory < ActiveRecord::Migration
  def up
    designCategory = Category.find_by_title("design")
    designCategory.title = "art"
    designCategory.description = "art"
    designCategory.save
  end

  def down
  end
end
