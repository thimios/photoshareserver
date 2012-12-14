
class PasswordsController < Devise::PasswordsController
  prepend_before_filter :require_no_authentication
  skip_authorization_check

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      flash_message = :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?

      respond_with resource, :location => "/"
    else
      respond_with resource
    end
  end


end
