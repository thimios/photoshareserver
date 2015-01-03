module Api
  module V1

    class ApplicationController < ActionController::Base
      protect_from_forgery
      respond_to :json

      # the api is always available to all logged in users
      skip_authorization_check

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
          user = User.find_by_authentication_token(params['auth_token'])
          if user.nil?
            user = request.env['warden'].authenticate(:scope => :user)
          end
          if user.nil?
            respond_to do |format|
              format.json {
                render :json => {:error => "Please authenticate again"}, status: :unauthorized
              }
            end
          else
            old_current, new_current = user.current_sign_in_at, Time.now.utc
            user.last_sign_in_at     = old_current || new_current
            user.current_sign_in_at  = new_current
          end
        else
          authenticate_user!
        end
      end

      protected

      def process_filter_params
        if params[:filter]
          filter = ActiveSupport::JSON.decode(params[:filter])
          params[filter[0].values[0]] = filter[0].values[1]
        end
      end
    end
  end
end