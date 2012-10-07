class SessionsController < Devise::SessionsController
  #include Devise::Controllers::Helpers
  prepend_before_filter :require_no_authentication, :only => [:new, :create]

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def new
    super
  end

  def create
    respond_to do |format|
      format.html { super}
      format.json {
        user = warden.authenticate(:scope => :user)
        if user
          user.reset_authentication_token!
          render :json => {:auth_token => user.authentication_token, :token_type => "persistant"}, :callback => params[:callback]
        else
          render :json => {:error => "invalid_grant"}, :callback => params[:callback]
        end

      }
    end


  end

end
