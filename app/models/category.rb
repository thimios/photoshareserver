class Category < ActiveRecord::Base
  attr_accessible :description, :title
  has_many :photos, :inverse_of => :category
  validates :title, :presence => true

  searchable do
    text :description, :title
  end

end
