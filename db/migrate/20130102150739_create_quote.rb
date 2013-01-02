class CreateQuote < ActiveRecord::Migration
  def up
    quote = Quote.find_or_create_by_content(
            :content => "So Berlin! Inspire and get inspired",
        )
    quote.save
  end

  def down
  end
end
