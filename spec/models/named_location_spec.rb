require 'rails_helper'

describe NamedLocation, :type => :model do

  describe "followed by current user" do
    it 'is true or false depending on whether the current user follows the named location' do
      current_user = create :user
      location = create :named_location
      location.current_user = current_user
      expect(location.followed_by_current_user).to eq("false")
      current_user.follow location
      expect(location.followed_by_current_user).to eq("true")
    end
  end

  context "location without photos" do
    it "should have default avatar" do
      location = create :named_location
      defaultavatar = create :system_photo, :default_avatar
      expect(location.small_size_url).to_not be_nil
      expect(defaultavatar.thumb_size_url).to eq(location.small_size_url)
    end
  end

end