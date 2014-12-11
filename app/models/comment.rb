# Users can comment on photos
class Comment < ActiveRecord::Base
  opinio counter_cache: true

  # tracked for user's activity feeds
  include PublicActivity::Model

  unless Rails.env.test?
    # TODO controllers should not be referenced in the model
    tracked :owner => proc { |controller, model| controller.current_user }, :recipient => proc { |controller, model|
      model.commentable
    }
  end

  # destroy all activity records on destroy
  has_many :activities, :class_name => "::PublicActivity::Activity", :as => :trackable, :dependent => :destroy

  def owner_username
    self.owner.username
  end

  def owner_thumb_size_url
    self.owner.thumb_size_url
  end

  def created_at_date
    self.created_at.strftime("%d %b. %Y")
  end

  def as_json(options={})
    super(options.reverse_merge(:methods => [:owner_username, :owner_thumb_size_url, :created_at_date]))
  end

end
