require 'rails_helper'

describe Photo, :type => :model do

  describe "#show_on_map" do
    it 'saves the attribute' do
      photo = create :photo
      photo.update_attribute :show_on_map, true
      expect(photo.show_on_map).to be(true)
      photo.update_attribute :show_on_map, false
      expect(photo.show_on_map).to be(false)
    end
  end

  describe '#latitude_not_null, #longitude_not_null' do
    context "coordinates initialized nil" do
      it 'sets default coordinates' do
        first_photo  = create(:photo, latitude: nil, longitude: nil, show_on_map: true)
        expect( first_photo.latitude_not_null).to be(90.0)
        expect( first_photo.longitude_not_null).to be(0.0)
      end
    end

    context "coordinates initialized not nil" do
      it 'keeps initialized coordinates' do
        first_photo  = create(:photo, latitude: 51.2, longitude: 10.3, show_on_map: true)
        expect(first_photo.latitude_not_null).to be(51.2)
        expect(first_photo.longitude_not_null).to be(10.3)
      end
    end
  end

end