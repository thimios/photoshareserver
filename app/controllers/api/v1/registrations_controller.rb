module Api
  module V1
    # TODO: currently it extends ApplicationController and not API::V1::ApplicationController
    class RegistrationsController < Devise::RegistrationsController
      require_dependency 'api/v1/user_search'

      # the api is always available to all logged in users
      skip_authorization_check

      respond_to :json

      # list users followed by specific user: http://localhost:3000/api/v1/users?followed_by_user_id=5
      # list users following a specific user: http://localhost:3000/api/v1/users?following_the_user_id=5
      # list users you are following: http://localhost:3000/api/v1/users?followed_by_current_user=true
      # list users following you: http://localhost:3000/api/v1/users?following_the_current_user=true
      def index
        my_authenticate_user
        process_filter_params

        if params[:followed_by_current_user] == "true"
          @users, @total_count = UserSearch.followed_by_current_user current_user, params[:page], params[:limit]
        elsif params[:following_the_current_user] == "true"
          @users = User.where(:id => current_user.followers.map{|follower_user| follower_user.id}).order("username").page(params[:page]).per(params[:limit])
          @total_count = @users.total_count
        elsif params[:followed_by_user_id]
          @users, @total_count = UserSearch.followed_by_user params[:followed_by_user_id], params[:page], params[:limit]
        elsif params[:following_the_user_id]
          @users = User.where(:id => User.find(params[:following_the_user_id]).followers.map{|follower_user| follower_user.id}).order("username").page(params[:page]).per(params[:limit])
          @total_count = @users.total_count
        elsif params[:search_string].blank?
          @users = User.page(params[:page]).per(params[:limit])
          @total_count = @users.total_count
        else
          @users, @total_count = UserSearch.full_text_search params[:search_string], params[:page], params[:limit]
        end

        # set current_user on all users before calling voted_by_current_user
        @users.each { |user|
          user.current_user = current_user
        }

        records_as_json = @users.as_json( :except => [:email, :address,:longitude, :latitude, :gender, :birth_date ] )
        render :json =>  { :records => records_as_json, :total_count => @total_count }
      end

      def suggested_followable_users
        my_authenticate_user
        @users, @total_count = UserSearch.suggest_followable_users(current_user, params[:page], params[:limit])

        records_as_json = @users.map{|user| user.as_json( :except => [:email, :address,:longitude, :latitude, :gender, :birth_date, :admin, :superadmin ] )  }
        render :json =>  { :records => records_as_json, :total_count => @total_count }
      end

      def create
        # default user avatar
        imagefile = File.open(Rails.root.join('app/assets', 'images', "defaultavatar.png"))
        params[:registration][:avatar] = imagefile
        params[:registration].delete( :thumb_size_url)
        params[:registration][:address] = "Urbanstrasse 66, 10967, Berlin, Germany"
        user = User.new(params[:registration])
        if user.save
          # on successful registration, user is directly logged in
          user.reset_authentication_token!
          user.current_user= user
          render :json=> user.as_json, :status=>201
        else
          render :json => { :errors =>user.errors },:status=>422
        end
      end

      # PUT /resource
      # We need to use a copy of the resource because we don't want to change
      # the current user in place.
      def update
        my_authenticate_user
        self.resource = current_user

        unless params[:birth_date1i].nil?
          params["birth_date(1i)"] = params[:birth_date1i]
          params.delete(:birth_date1i)
        end

        unless params[:birth_date2i].nil?
          params["birth_date(2i)"] = params[:birth_date2i]
          params.delete(:birth_date2i)
        end

        unless params[:birth_date3i].nil?
          params["birth_date(3i)"] = params[:birth_date3i]
          params.delete(:birth_date3i)
        end

        user_params = params.reject{|key, value| key.in?(["_method","authenticity_token","commit","auth_token","action","controller","format"])}

        if resource.update_with_password(user_params)
          if is_navigational_format?
            if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
              flash_key = :update_needs_confirmation
            end
            set_flash_message :notice, flash_key || :updated
          end
          sign_in resource_name, resource, :bypass => true
          respond_with resource, :location => after_update_path_for(resource)
        else
          clean_up_passwords resource
          render :json => { :errors =>resource.errors },:status=> :ok #phonegap fileuploader cannot handle data on failure
        end
      end

      # GET /users/1
      # GET /users/1.json
      # Show user's public profile
      def show
        my_authenticate_user
        users = Array.new
        @user = (User.find(params[:id]))

        @activities = PublicActivity::Activity.where(:owner_id =>params[:id])

        users[0] = @user

        # set current_user on all users before calling voted_by_current_user
        users.each { |user|
          user.current_user = current_user
        }

        unless params[:id].eql? (current_user.id.to_s)
          records_as_json = users.as_json( :except => [:email, :address,:longitude, :latitude, :gender, :birth_date ] )
        else
          records_as_json = users.as_json()
        end
        render json: records_as_json

      end

      def follow
        my_authenticate_user
        @user = User.find(params[:id])
        current_user.follow(@user)
        render json: [notice: 'You are now following '+@user.username], status: 200
      end

      def unfollow
        my_authenticate_user
        @user = User.find(params[:id])
        current_user.stop_following(@user)
        render  json: [ notice => 'You are not following '+@user.username + " any more."  ], status: 200
      end

    end
  end
end