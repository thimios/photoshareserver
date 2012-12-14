class SystemPhoto < ActiveRecord::Base
  attr_accessible :title, :image

  has_attached_file :image,
                    :styles => { :full => "640x640", :medium => "460x460>", :thumb => "80x80>" }
  def original_size_url
    image.url
  end

  def full_size_url
    image.url(:full)
  end

  def medium_size_url
    image.url(:medium)
  end

  def thumb_size_url
    image.url(:thumb)
  end

  validates :image, :attachment_presence => true

end
