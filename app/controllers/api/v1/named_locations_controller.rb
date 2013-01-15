module Api
  module V1
    class NamedLocationsController < ApplicationController
      before_filter :my_authenticate_user
      # the api is always available to all logged in users
      skip_authorization_check

      def follow
        location = NamedLocation.find_by_google_id params[:location_google_id]
        current_user.follow(location)
        current_user.reindex
        render json: [notice: 'You are now following this location.'], status: 200
      end

      def unfollow
        location = NamedLocation.find_by_google_id params[:location_google_id]
        current_user.stop_following(location)
        current_user.reindex
        render  json: [ notice => 'You are not following this location any more.'  ], status: 200
      end
#
#      # GET /named_locations/1
#      # GET /named_locations/1.json
#      def show
#        @named_location = NamedLocation.find(params[:id])
#
#        respond_to do |format|
#          format.html # show.html.erb
#          format.json { render json: @named_location }
#        end
#      end
#
#      # GET /named_locations/new
#      # GET /named_locations/new.json
#      def new
#        @named_location = NamedLocation.new
#
#        respond_to do |format|
#          format.html # new.html.erb
#          format.json { render json: @named_location }
#        end
#      end
#
#      # GET /named_locations/1/edit
#      def edit
#        @named_location = NamedLocation.find(params[:id])
#      end
#
#      # POST /named_locations
#      # POST /named_locations.json
#      def create
#        @named_location = NamedLocation.new(params[:named_location])
#
#        respond_to do |format|
#          if @named_location.save
#            format.html { redirect_to @named_location, notice: 'Named location was successfully created.' }
#            format.json { render json: @named_location, status: :created, location: @named_location }
#          else
#            format.html { render action: "new" }
#            format.json { render json: @named_location.errors, status: :unprocessable_entity }
#          end
#        end
#      end
#
#      # PUT /named_locations/1
#      # PUT /named_locations/1.json
#      def update
#        @named_location = NamedLocation.find(params[:id])
#
#        respond_to do |format|
#          if @named_location.update_attributes(params[:named_location])
#            format.html { redirect_to @named_location, notice: 'Named location was successfully updated.' }
#            format.json { head :no_content }
#          else
#            format.html { render action: "edit" }
#            format.json { render json: @named_location.errors, status: :unprocessable_entity }
#          end
#        end
#      end
#
#      # DELETE /named_locations/1
#      # DELETE /named_locations/1.json
#      def destroy
#        @named_location = NamedLocation.find(params[:id])
#        @named_location.destroy
#
#        respond_to do |format|
#          format.html { redirect_to named_locations_url }
#          format.json { head :no_content }
#        end
#      end
    end
  end
end

