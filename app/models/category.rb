# Photos have categories that are setup in the database during the initial seeding.
# Categories are not being added or deleted
class Category < ActiveRecord::Base
  attr_accessible :description, :title, :display_title
  has_many :photos, :inverse_of => :category
  validates :title, :presence => true
end
