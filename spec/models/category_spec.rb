require 'rails_helper'

describe Category, :type => :model do
  fixtures :all
  it "should validate presence of title" do
    expect(subject).to validate_presence_of :title
  end

  it "should always have three standard categories with predefined ids" do
    fashion = Category.find_by_title "fashion"
    place = Category.find_by_title "place"
    art = Category.find_by_title "art"
    expect(fashion.id).to be(1)
    expect(place.id).to be(2)
    expect(art.id).to be(3)
  end
end