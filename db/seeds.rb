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

Photo.find_or_create_by_title(title: "fashion photo test", description: "belonging to fashion category", category_id: "1", address: "Urbanstrasse 66, Berlin, Germany")
Photo.find_or_create_by_title(title: "fashion photo test2", description: "belonging to fashion category", category_id: "1", address: "Urbanstraße 30, Berlin, Deutschland")

Photo.find_or_create_by_title(title: "place photo test", description: "belonging to place category", category_id: "2", address: "Dieffenbachstraße 54, 10967 Berlin, Germany")
Photo.find_or_create_by_title(title: "place photo test2", description: "belonging to place category", category_id: "2", address: "Dieffenbachstraße 62, 10967 Berlin, Germany")

Photo.find_or_create_by_title(title: "design photo test", description: "belonging to design category", category_id: "3", address: "Graefestraße 71, 10967 Berlin, Germany")
Photo.find_or_create_by_title(title: "design photo test2", description: "belonging to design category", category_id: "3", address: "Grimmstraße 24, 10967 Berlin, Germany")



#password: dimo5217

user1 =
  User.find_or_create_by_email(
    :username => "thimios",
    :birth_date => "2010-09-28 00:00:00",
    :gender => "male",
    :email => "thimios@wantedpixel.com",
    :password => 'thimios',
    :password_confirmation => 'thimios')
user1.confirm!
user1.save 

user2 =
  User.find_or_create_by_email(
    :username => "spiros",
    :birth_date => "2010-09-28 00:00:00",
    :gender => "male",
    :email => "spiros@wantedpixel.com",
    :password => 'spiros',
    :password_confirmation => 'spiros')
user2.confirm!
user2.save 
