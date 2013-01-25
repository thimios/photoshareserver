require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  fixtures :categories, :users, :photos, :comments

  test "as_json should include fields" do
    c = comments(:comments_001)
    json = c.as_json

    assert_not_nil json

    assert_equal json["body"], c.body
    assert_equal json["commentable_id"], c.commentable.id

    assert_not_nil json["owner_username"]
    assert_not_nil json['owner_thumb_size_url']
    assert_not_nil json['created_at_date']
  end

end
