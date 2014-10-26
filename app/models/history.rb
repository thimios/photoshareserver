# User actions are captured as History objects
class History

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :created_at, #date, time string
                :created_at_date,
                :title, #Posted a photo, Commented on Jimmy's photo, Liked Jimmy's photo
                :description, #either the comment or the photo description
                :photo_id, # the id of the photo posted, liked or commented
                :comment_id, # the id of the posted comment, or blank
                :thumb_url, # the url of the thumbnail of the photo posted, liked or commented
                :actor_id, # the user id of the user that liked or commented the photo. It could equal to photo owner id
                :actor_followed_by_current_user # is the actor followed by the current user, self, true, false

  def self.attr_accessor(*vars)
    @attributes ||= []
    @attributes.concat( vars )
    super
  end

  def self.attributes
    @attributes
  end

  def initialize(attributes={})
    attributes && attributes.each do |name, value|
      send("#{name}=", value) if respond_to? name.to_sym
    end
  end

  def persisted?
    false
  end

  def self.inspect
    "#<#{ self.to_s} #{ self.attributes.collect{ |e| ":#{ e }" }.join(', ') }>"
  end

end

