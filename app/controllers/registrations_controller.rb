class RegistrationsController < Devise::RegistrationsController
  layout "home"

  def create

    if params[:signed_request].blank?

      # this is not a facebook callback, we just set the default avatar and call super
      imagefile = File.open(Rails.root.join('app/assets', 'images', "defaultavatar.png"))
      params[:user][:avatar] = imagefile
    else

      # this is a facebook callback, we decode the user params and proceed with super
      signed_request = params[:signed_request]
      signature, str = signed_request.split('.')
      str += '=' * (4 - str.length.modulo(4))
      params_decoded = ActiveSupport::JSON.decode(Base64.decode64(str.gsub("-", "+").gsub("_", "/")))

      params[:user] = params_decoded['registration']
      params[:user][:birth_date] = params[:user][:birthday]
      logger.debug(params)
      imagefile = File.open(Rails.root.join('app/assets', 'images', "defaultavatar.png"))
      params[:user][:avatar] = imagefile

      params[:user][:address] = "Urbanstrasse 66, 10967, Berlin, Germany"
      params[:user].delete('name')
      params[:user].delete('birthday')
      params[:user].delete('repeat_password')
    end

    super
  end




  def messages
     render 'devise/registrations/messages'
  end


  ## PUT /resource
  ## We need to use a copy of the resource because we don't want to change
  ## the current user in place.
  #def update
  #  self.resource = current_user
  #
  #  unless params[:birth_date1i].nil?
  #    params["birth_date(1i)"] = params[:birth_date1i]
  #    params.delete(:birth_date1i)
  #  end
  #
  #  unless params[:birth_date2i].nil?
  #    params["birth_date(2i)"] = params[:birth_date2i]
  #    params.delete(:birth_date2i)
  #  end
  #
  #  unless params[:birth_date3i].nil?
  #    params["birth_date(3i)"] = params[:birth_date3i]
  #    params.delete(:birth_date3i)
  #  end
  #
  #
  #  user_params = params.reject{|key, value| key.in?(["_method","authenticity_token","commit","auth_token","action","controller","format"])}
  #
  #  if resource.update_with_password(user_params)
  #    if is_navigational_format?
  #      if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
  #        flash_key = :update_needs_confirmation
  #      end
  #      set_flash_message :notice, flash_key || :updated
  #    end
  #    sign_in resource_name, resource, :bypass => true
  #    respond_with resource, :location => after_update_path_for(resource)
  #  else
  #    clean_up_passwords resource
  #    respond_with resource
  #  end
  #end

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