class Comment < ActiveRecord::Base
  opinio

  # tracked for user's activity feeds
  include PublicActivity::Model
  tracked :owner => proc { |controller, model| controller.current_user }

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
