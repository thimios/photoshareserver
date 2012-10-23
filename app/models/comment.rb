class Comment < ActiveRecord::Base
  opinio

  # tracked for user's activity feeds
  include PublicActivity::Model
  tracked :owner => proc { |controller, model| controller.current_user }

  def owner_username
    self.owner.username
  end

  def as_json(options={})
    super(options.reverse_merge(:methods => :owner_username))
  end

end
