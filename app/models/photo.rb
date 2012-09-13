class Photo < ActiveRecord::Base
  attr_accessible :category_id, :description, :title
  belongs_to :category, :touch => true, :inverse_of => :photos
  validates :category_id, :presence => true
end
