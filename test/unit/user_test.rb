require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :categories, :users

  test "plusminus" do
    generator = Random.new
    # photos created by first user
    total_votes_on_photos_of_first_user = 0
    5.times do
      photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: rand(1..3), user_id: 1, latitude: generator.rand(52.2..59.7), longitude: generator.rand(12.3..17.5), track_location: "yes")
      photo.created_at = rand(0.2..0.7).hours.ago
      photo.save

      photo_votes_count = rand(0..10)
      users = User.order('RAND()').limit(photo_votes_count)
      users.each {|user|
        user.vote_for (photo)
      }
      total_votes_on_photos_of_first_user += photo_votes_count
    end

    # photos created by all other users
    15.times do
      photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: rand(1..3), user_id: generator.rand(2..10), latitude: generator.rand(52.2..59.7), longitude: generator.rand(12.3..17.5), track_location: "yes")
      photo.created_at = rand(0.2..0.7).hours.ago
      photo.save


      users = User.order('RAND()').limit(rand(0..10))
      users.each {|user|
        user.vote_for (photo)
      }
    end

    assert_equal(User.find(1).plusminus, total_votes_on_photos_of_first_user, "User plusminus should be the sum of vote count on user's photos")

  end

end
