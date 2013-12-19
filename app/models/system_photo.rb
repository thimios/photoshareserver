class SystemPhoto < ActiveRecord::Base
  attr_accessible :title, :image

  has_attached_file :image,
                    :styles => { :full => "640x640", :medium => "460x460>", :thumb => "160x160>" }
  def original_size_url
    "http://#{ActionMailer::Base.default_url_options[:host]}#{image.url}"
  end

  def full_size_url
    "http://#{ActionMailer::Base.default_url_options[:host]}#{image.url(:full)}"
  end

  def medium_size_url
    "http://#{ActionMailer::Base.default_url_options[:host]}#{image.url(:medium)}"
  end

  def thumb_size_url
    "http://#{ActionMailer::Base.default_url_options[:host]}#{image.url(:thumb)}"
  end

  validates :image, :attachment_presence => true

end
