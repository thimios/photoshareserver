require 'rails_helper'

describe NamedLocation, :type => :model do
  subject { create :named_location }
  describe "best_photo" do
    it "returns nil if the location has no photos" do
      expect(subject.photos_count).to be 0
      expect(subject.best_photo).to be nil
    end
  end

  describe "small_size_url" do
    context "without photos" do
      it "returns the default url" do
        create :system_photo, :default_avatar
        expect(subject.photos_count).to be 0
        expect(subject.small_size_url).to be == SystemPhoto.find_by_title("default avatar").thumb_size_url
      end
    end

    context "with photos" do
      it "returns the url of the photo of the location" do
        subject = create :named_location, :with_one_photo
        Photo.reindex
        expect(subject.small_size_url).to be == subject.photos.first.thumb_size_url
      end
    end

  end

  describe "followed by current user" do
    it 'is true or false depending on whether the current user follows the named location' do
      current_user = create :user
      subject.current_user = current_user
      expect(subject.followed_by_current_user).to eq("false")
      current_user.follow subject
      expect(subject.followed_by_current_user).to eq("true")
    end
  end

  context "location without photos" do
    it "should have default avatar" do
      defaultavatar = create :system_photo, :default_avatar
      expect(subject.small_size_url).to_not be_nil
      expect(defaultavatar.thumb_size_url).to eq(subject.small_size_url)
    end
  end

end