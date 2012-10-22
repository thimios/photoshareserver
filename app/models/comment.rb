class Comment < ActiveRecord::Base
  opinio

  # tracked for user's activity feeds
  include PublicActivity::Model
  tracked :owner => proc { |controller, model|
    unless controller.nil?
      controller.current_user
    else
      User.find(1)
    end
  }

  def owner_username
    self.owner.username
  end

  def as_json(options={})
    super(options.reverse_merge(:methods => :owner_username))
  end

end
