module Api
  module V1

    class ApplicationController < ActionController::Base
      protect_from_forgery
      respond_to :json

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
      end
    end
  end
end