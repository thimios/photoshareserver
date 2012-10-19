# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Category.find_or_create_by_title(title: "fashion", description: "fashion passion")
Category.find_or_create_by_title(title: "place", description: "places category")
Category.find_or_create_by_title(title: "design", description: "design")

imagefile = File.open(File.join(Rails.root, 'test', 'fixtures','lost-hipster.jpg'))

photo1 = Photo.find_or_create_by_title(title: "fashion photo test", description: "belonging to fashion category", category_id: "1", user_id: "1", address: "Urbanstrasse 66, Berlin, Germany", image: imagefile)
photo2 = Photo.find_or_create_by_title(title: "fashion photo test2", description: "belonging to fashion category", category_id: "1", user_id: "2", address: "Urbanstraße 30, Berlin, Deutschland", image: imagefile)

photo3 = Photo.find_or_create_by_title(title: "place photo test", description: "belonging to place category", category_id: "2", user_id: "1", address: "Dieffenbachstraße 54, 10967 Berlin, Germany", image: imagefile)
photo4 = Photo.find_or_create_by_title(title: "place photo test2", description: "belonging to place category", category_id: "2", user_id: "2", address: "Dieffenbachstraße 62, 10967 Berlin, Germany", image: imagefile)

photo5 = Photo.find_or_create_by_title(title: "design photo test", description: "belonging to design category", category_id: "3", user_id: "1", address: "Graefestraße 71, 10967 Berlin, Germany", image: imagefile)
photo6 = Photo.find_or_create_by_title(title: "design photo test2", description: "belonging to design category", category_id: "3", user_id: "2", address: "Grimmstraße 24, 10967 Berlin, Germany", image: imagefile)

generator = Random.new

60.times do
   Photo.create(title: Faker::Lorem.sentence(2), description: Faker::Lorem.sentence(3), category_id: generator.rand(1..3), user_id: generator.rand(1..2), latitude: generator.rand(52.2..54.7), longitude: generator.rand(12.3..14.5), image: imagefile)
end


user1 =
  User.find_or_create_by_email(
    :username => "thimios",
    :birth_date => "2010-09-28 00:00:00",
    :gender => "male",
    :email => "thimios@wantedpixel.com",
    :password => 'thimios',
    :password_confirmation => 'thimios',
    :address => 'urbanstrasse 66, 10967 Berlin, Germany',
    :avatar => imagefile)
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
    :avatar => imagefile )
user2.confirm!
user2.geocode
user2.save

unless user1.voted_on? (photo1)
  user1.vote_for (photo1)
end

unless user1.voted_on? (photo2)
  user1.vote_for(photo2)
end

unless user2.voted_on? (photo2)
  user2.vote_for(photo2)
end


100.times do
  comment = photo1.comments.build( body: Faker::Lorem.sentence(3) )
  comment.owner = user1
  comment.save
end
