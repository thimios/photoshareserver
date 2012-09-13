class Category < ActiveRecord::Base
  attr_accessible :description, :title
  has_many :photos, :inverse_of => :category
end
