require 'rails_helper'

describe User, :type => :model do
  describe "#plusminus" do

    it "sums votes on user's photos" do
      first_user = create :user
      photos_by_first_user = create_list(:photo,5, user: first_user)
      voters = create_list(:user, 10)

      total_votes_on_photos_of_first_user = 0
      photos_by_first_user.each do |photo|
        photo_voters = voters.sample rand(0..10)
        photo_voters.each do |voter|
          voter.vote_for photo
          total_votes_on_photos_of_first_user += 1
        end
      end

      other_users = create_list(:user, 10)
      other_users.each do |user|
        photo = create :photo, user: user
        photo_voters = voters.sample rand(0..10)
        photo_voters.each do |voter|
          voter.vote_for photo
        end
      end
      expect(first_user.plusminus).to eq(total_votes_on_photos_of_first_user)
    end

  end

  describe "#followed_by_current_user" do
    context "current user is self" do
      it "should be self" do
        user = create :user
        user.current_user = user

        expect(user.followed_by_current_user).to eq("self")
      end
    end
  end

end