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
