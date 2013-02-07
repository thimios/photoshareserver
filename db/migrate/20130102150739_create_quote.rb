class CreateQuote < ActiveRecord::Migration
  def up
    Quote.find_or_create_by_content(:content => "So Berlin! Inspire and get inspired")
  end

  def down
  end
end
