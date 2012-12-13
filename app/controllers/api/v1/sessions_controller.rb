module Api
  module V1

    class SessionsController < Devise::SessionsController
      #include Devise::Controllers::Helpers
      prepend_before_filter :require_no_authentication, :only => [:new, :create]
      # the api is always available to all logged in users
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

      def create
        warden.custom_failure!
        user = warden.authenticate(:scope => :user)

        if !user.nil?
          user.reset_authentication_token!
          render :json => {:auth_token => user.authentication_token, :token_type => "persistant", :user_id => user.id}, :callback => params[:callback]
        else
          user = User.find_by_email (params['user']['email'])
          if !user.nil? and !user.confirmed?
            render :json => {:error => "Please confirm your email address before logging in. Check your email!"}, status: :unauthorized
          else
            render :json => {:error => "Invalid username or password"}, status: :unauthorized
          end
        end
      end
    end
  end
end
