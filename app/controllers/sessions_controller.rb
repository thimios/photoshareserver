class SessionsController < Devise::SessionsController
  #include Devise::Controllers::Helpers
  prepend_before_filter :require_no_authentication, :only => [:new, :create]
  skip_authorization_check

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
end
