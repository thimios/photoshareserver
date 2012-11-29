module Api
  module V1

    class PasswordsController < Devise::PasswordsController
      prepend_before_filter :require_no_authentication
      respond_to :json

      # POST /resource/password
      def create
        self.resource = User.send_reset_password_instructions(params)
        if successfully_sent?(resource)
          render :json => { :message => "You will receive an email with instructions about how to reset your password in a few minutes." },:status=> :ok #phonegap fileuploader cannot handle data on failure
        else
          render :json => { :message => "The email you typed was not found." },:status=> :unprocessable_entity
        end
      end


    end
  end
end