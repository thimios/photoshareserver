class ApplicationController < ActionController::Base
  protect_from_forgery
  check_authorization

  after_filter :set_access_control_headers

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

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

  def after_sign_in_path_for(resource)
    sign_in_url = url_for(:action => 'new', :controller => 'sessions', :only_path => false, :protocol => 'http')
    if resource.admin?
      admin_path
    else
      root_path
    end
  end

end
