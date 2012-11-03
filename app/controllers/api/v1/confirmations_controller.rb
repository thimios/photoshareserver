module Api
  module V1

    class ConfirmationsController < Devise::ConfirmationsController
      # GET /resource/confirmation?confirmation_token=abcdef
      def show
        self.resource = resource_class.confirm_by_token(params[:confirmation_token])

        if resource.errors.empty?
          set_flash_message(:notice, :confirmed) if is_navigational_format?
          # sign_in(resource_name, resource)
          respond_with_navigational(resource){ redirect_to "/" }
        else
          respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
        end
      end
    end
  end
end