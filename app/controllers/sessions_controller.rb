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
          render :json => {:auth_token => user.authentication_token, :token_type => "persistant", :user_id => user.id}, :callback => params[:callback]
        else
          render :json => {:error => "Invalid username or password"}, status: :unauthorized, :callback => params[:callback]
        end
      }
    end


  end

end
