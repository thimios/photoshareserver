class RegistrationsController < Devise::RegistrationsController
  layout "home"

  def create
    if params[:signed_request].blank?
      parse_facebook_params! params
    end
    super
  end


  def messages
     render 'devise/registrations/messages'
  end

  def follow
    my_authenticate_user
    @user = User.find(params[:id])
    current_user.follow(@user)
    redirect_to "/users/#{@user.id}", notice: 'You are now following '+@user.username
  end

  def unfollow
    my_authenticate_user
    @user = User.find(params[:id])
    current_user.stop_following(@user)
    redirect_to "/users/#{@user.id}", notice: 'You are not following '+@user.username + " any more."
  end

  protected

  def parse_facebook_params! params
    # this is a facebook callback, we decode the user params and proceed with super
    signed_request = params[:signed_request]
    signature, str = signed_request.split('.')
    str += '=' * (4 - str.length.modulo(4))
    params_decoded = ActiveSupport::JSON.decode(Base64.decode64(str.gsub("-", "+").gsub("_", "/")))

    params[:user] = params_decoded['registration']
    params[:user][:birth_date] = params[:user][:birthday]

    params[:user][:avatar] = File.open(Rails.root.join('app/assets', 'images', "defaultavatar.png"))

    params[:user][:address] = "Urbanstrasse 66, 10967, Berlin, Germany"
    params[:user].delete('name')
    params[:user].delete('birthday')
    params[:user].delete('repeat_password')
  end


  # The path used after sign up. You need to overwrite this method
  # in your own RegistrationsController.
  def after_sign_up_path_for(resource)
    '/users/messages'
  end

  # The path used after sign up for inactive accounts. You need to overwrite
  # this method in your own RegistrationsController.
  def after_inactive_sign_up_path_for(resource)
    '/users/messages'
  end

end