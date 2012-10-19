class Comment < ActiveRecord::Base
  opinio

  def owner_username
    self.owner.username
  end
end
