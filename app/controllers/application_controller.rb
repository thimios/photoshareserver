class ApplicationController < ActionController::Base
  protect_from_forgery

  opinio_identifier do |params|
    next Photo.find(params[:photo_id]) if params[:photo_id]
  end

  comment_destroy_conditions do |comment|
    comment.owner == current_user
  end

  # setting current_user as owner for activity
  include PublicActivity::StoreController

end
