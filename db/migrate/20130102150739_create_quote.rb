class CreateQuote < ActiveRecord::Migration
  def up
    Quote.find_or_create_by_content(:content => "test quote")
  end

  def down
  end
end
