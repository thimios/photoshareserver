# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# disable activity logging while seeding
PublicActivity.enabled= false

Category.find_or_create_by_title(title: "fashion", description: "fashion passion")
Category.find_or_create_by_title(title: "place", description: "places category")
Category.find_or_create_by_title(title: "art", description: "art")

imagefile = File.open(File.join(Rails.root, 'app', 'assets', 'images', 'seed.jpg'))

user1 =
    User.find_or_create_by_email(
        :username => "thimios",
        :birth_date => "2010-09-28 00:00:00",
        :gender => "male",
        :email => "thimios@wantedpixel.com",
        :password => 'thimios',
        :password_confirmation => 'thimios',
        :address => 'urbanstrasse 66, 10967 Berlin, Germany',
        :avatar => imagefile,
        :admin => true,
        :superadmin => true
    )
user1.confirm!
user1.geocode
user1.save

user2 =
    User.find_or_create_by_email(
        :username => "spiros",
        :birth_date => "2010-09-28 00:00:00",
        :gender => "male",
        :email => "spiros@wantedpixel.com",
        :password => 'spiros',
        :password_confirmation => 'spiros',
        :address => 'Schlegelstrasse 15, 10115 Berlin, Germany',
        :avatar => imagefile,
        :admin => true,
        :superadmin => true
    )
user2.confirm!
user2.geocode
user2.save

user3 =
    User.find_or_create_by_email(
        :username => "soberlin",
        :birth_date => "2010-09-28 00:00:00",
        :gender => "male",
        :email => "info.soberlin@gmail.com",
        :password => 'Bernvero1',
        :password_confirmation => 'Bernvero1',
        :address => 'Schlegelstrasse 15, 10115 Berlin, Germany',
        :avatar => imagefile,
        :admin => true,
        :superadmin => false
    )
user3.confirm!
user3.geocode
user3.save

generator = Random.new

30.times do
  photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 1, user_id: generator.rand(1..2), latitude: generator.rand(52.2..54.7), longitude: generator.rand(12.3..14.5), image: imagefile, track_location: "yes")
  20.times do
   comment = photo.comments.build( body: Faker::Lorem.sentence(3) )
   comment.owner = user2
   comment.save
  end

  user1.vote_for ( photo)
  user2.vote_for( photo)

end

30.times do
  photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 2, user_id: generator.rand(1..2), latitude: generator.rand(52.2..54.7), longitude: generator.rand(12.3..14.5), image: imagefile, track_location: "yes")
  20.times do
    comment = photo.comments.build( body: Faker::Lorem.sentence(3) )
    comment.owner = user1
    comment.save
  end

  user1.vote_for ( photo)

  report = PhotoReport.create(:photo_id => photo.id, :user_id => user1.id)
  report.save
end

30.times do
  photo = Photo.create(title: Faker::Lorem.sentence(2).truncate(23), category_id: 3, user_id: generator.rand(1..2), latitude: generator.rand(52.2..54.7), longitude: generator.rand(12.3..14.5), image: imagefile, track_location: "yes")
  20.times do
    comment = photo.comments.build( body: Faker::Lorem.sentence(3) )
    comment.owner = user2
    comment.save

  end
  user2.vote_for( photo)
  report = PhotoReport.create(:photo_id => photo.id, :user_id => user1.id)
  report.save
  report = PhotoReport.create(:photo_id => photo.id, :user_id => user2.id)
  report.save
end

bannedimagefile = File.open(File.join(Rails.root, 'app', 'assets','images','bannedphoto.png'))
SystemPhoto.create(title: "banned image", image: bannedimagefile)




