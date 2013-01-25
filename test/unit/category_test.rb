require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  fixtures :categories
  test "title should not be empty" do
    c = Category.new
    assert !c.save
  end

  test "standard categories should have fixed titles and ids" do
    # fashion 1
    # place 2
    # art 3

    fashion = Category.find_by_title "fashion"
    place = Category.find_by_title "place"
    art = Category.find_by_title "art"

    assert_not_nil fashion
    assert_not_nil place
    assert_not_nil art

    assert_equal 1, fashion.id, "fashion category should have id 1"
    assert_equal 2, place.id, "place category should have id 2"
    assert_equal 3, art.id, "art category should have id 3"
  end

end
