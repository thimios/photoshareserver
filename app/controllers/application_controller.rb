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

  def my_authenticate_user
    if request.format == "application/json"
          user = request.env['warden'].authenticate(:scope => :user)
          if user.nil?
            respond_to do |format|
              format.json {
                render :json => {:error => "Please authenticate again"}, status: :unauthorized
              }
            end
          end
    else
      authenticate_user!
    end
    #format = request.format
    #if format == "application/json"
    #  user = request.env['warden'].authenticate
    #  if  user
    #    render :json=> user.as_json(:auth_token=>user.authentication_token, :email=>user.email), :status=>201
    #    return
    #  else
    #    render :json => { :error =>"Authentication error" },:status => 401
    #  end
    #else
    #  request.env['warden'].authenticate_user!
    #end
  end

end
