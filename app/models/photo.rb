class Photo < ActiveRecord::Base
  attr_accessible :category_id, :description, :title, :image
  belongs_to :category, :touch => true, :inverse_of => :photos
  has_attached_file :image, :styles => { :full => "800x800", :medium => "300x300>", :thumb => "100x100>" }
  
  
  validates :category_id, :presence => true
  #validates :image, :attachment_presence => true
end
