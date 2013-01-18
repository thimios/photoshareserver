module Api
  module V1
    class NamedLocationsController < ApplicationController
      before_filter :my_authenticate_user
      require_dependency 'location_search'
      # the api is always available to all logged in users
      skip_authorization_check

      def show
        @named_location = (NamedLocation.find_by_google_id(params[:id]))
        @named_location.current_user = current_user
        render json: @named_location.as_json()
      end

      def follow
        location = NamedLocation.find_by_google_id params[:location_google_id]
        current_user.follow(location)
        render json: [notice: 'You are now following this location.'], status: 200
      end

      def unfollow
        location = NamedLocation.find_by_google_id params[:location_google_id]
        current_user.stop_following(location)
        render  json: [ notice => 'You are not following this location any more.'  ], status: 200
      end

      def suggested_followable_locations
        @locations, @total_count = LocationSearch.suggest_followable_locations(current_user, params[:page], params[:limit])

        @records_as_json = @locations.map{|location| location.as_json  }
        render :json =>  { :records => @records_as_json, :total_count => @total_count }

      end

      def index
        if params[:filter]
          #get followed by current user
          @filter_params = HashWithIndifferentAccess.new
          @filter = ActiveSupport::JSON.decode(params[:filter])
          @filter_params[@filter[0].values[0]] = @filter[0].values[1]
          if @filter_params[:followed_by_current_user]
            params[:followed_by_current_user] = @filter_params[:followed_by_current_user]
          end
          @results = NamedLocation.where(:id => current_user.following_location_ids).page(params[:page]).per(params[:limit])
          @total_count = @results.total_count
        elsif !params[:search_string].blank?
          #get fulltext resutls
          @search = Sunspot.search (NamedLocation) do
            fulltext params[:search_string]
            paginate(:page => params[:page], :per_page => params[:limit])
          end
          @results = @search.results
          @total_count = @search.total
        else
          #get all
          @results = NamedLocation.page(params[:page]).per(params[:limit])
          @total_count = @results.total_count
        end

        # set current_user on all users before calling voted_by_current_user
        @results.each { |result|
          result.current_user = current_user
        }

        records_as_json = @results.as_json
        render :json =>  { :records => records_as_json, :total_count => @total_count }
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

