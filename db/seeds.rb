# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Task.create(name: "taks1")
Task.create(name: "task2")
Task.create(name: "skata")

Category.create(title: "fashion", description: "fashion passion")
Category.create(title: "place", description: "places category")
Category.create(title: "design", description: "design")

Photo.create(title: "fashion photo test", description: "belonging to fashion category", category_id: "1")
Photo.create(title: "fashion photo test2", description: "belonging to fashion category", category_id: "1")

Photo.create(title: "place photo test", description: "belonging to place category", category_id: "2")
Photo.create(title: "place photo test2", description: "belonging to place category", category_id: "2")

Photo.create(title: "design photo test", description: "belonging to design category", category_id: "3")
Photo.create(title: "design photo test2", description: "belonging to design category", category_id: "3")



#password: dimo5217

user1 =
  User.find_or_create_by_email(
    :email => "thimios@wantedpixel.com",
    :password => 'thimios',
    :password_confirmation => 'thimios')
user1.confirm!
user1.save 

user2 =
  User.find_or_create_by_email(
    :email => "spiros@wantedpixel.com",
    :password => 'spiros',
    :password_confirmation => 'spiros')
user2.confirm!
user2.save 
