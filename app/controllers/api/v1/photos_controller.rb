module Api
  module V1

    class PhotosController < ApplicationController
      before_filter :my_authenticate_user
      # the api is always available to all logged in users
      skip_authorization_check
      require_dependency 'api/v1/photo_search'

      # Returns the "best" ten markers according to our sorting algorithm, within a bounding box of coordinates
      #http://localhost:3000/api/v1/photos/indexbbox.json?_dc=1359735692603&sw_y=38.23493973799441&sw_x=21.736575518896416&ne_y=38.27962430368643&ne_x=21.764041339208916&fashion=true&art=true&place=true&auth_token=jFZkzcuoLHnEqWJe3DPF&current_markers=94%2C93
      def indexbbox
        current_photo_ids = params['current_markers'].split(',').map{ | item | item.to_i }

        # set categories according to filtering on the map
        categories = Array.new
        if params[:fashion] == "true"
          categories << 1
        end
        if params[:place] == "true"
          categories << 2
        end
        if params[:art] == "true"
          categories << 3
        end

        unless categories.empty?
          search = Sunspot.search (Photo) do
            #y latitude
            #x longitude
            # eager load user and named_location of each photo, to avoid N+1 queries
            data_accessor_for(Photo).include = [:user, :named_location]

            with(:coordinates).in_bounding_box([params[:sw_y], params[:sw_x]], [params[:ne_y], params[:ne_x]])
            with(:category_id,  categories)
            with(:show_on_map, true)

            paginate(:page => 1, :per_page => 60)
            order_by :created_at, :desc

          end

          photos = []

          location_ids = []
          search.results.each do |photo|
            if photo.named_location_id == nil || location_ids.index(photo.named_location_id) == nil
              photos.append photo
              if photo.named_location_id != nil
                location_ids.append photo.named_location_id
              end
            end
            if photos.length == 25
              break;
            end
          end

          # if location_google_id is set, the map for a named location details view is requested, so the best
          # photo of that location is always included
          unless params[:location_google_id].nil?
            detail_location = NamedLocation.find_by_google_id( params[:location_google_id])
            unless detail_location.nil?
              detail_photo = detail_location.best_photo
              unless detail_photo.nil?
                if photos.index(detail_photo).nil?
                  photos << detail_photo
                end
              end
            end
          end

          # if detail_photo_id param is set, the photo with that id will by all means be in the results
          unless params[:detail_photo_id].nil?
            detail_photo = Photo.find(params[:detail_photo_id])

            unless detail_photo.nil?
              if photos.index(detail_photo).nil?
                photos << detail_photo
              end
            end
          end

          # set current_user on all photos before calling voted_by_current_user
          photos.each { |photo|
            photo.current_user = current_user
          }

          new_photo_ids = photos.map{|photo| photo.id}

          to_remove_ids = current_photo_ids - new_photo_ids

          to_add_ids = new_photo_ids - current_photo_ids

          to_add_photos = []

          photos.each{ |photo|
            unless to_add_ids.index(photo.id).nil?
              to_add_photos << photo
            end
          }

          render :json => {:to_add_photos => to_add_photos, :to_remove_ids => to_remove_ids}
        else
          # no markers should be displayed, remove all of them
          to_remove_ids = current_photo_ids
          to_add_photos = []
          render :json => {:to_add_photos => to_add_photos, :to_remove_ids => to_remove_ids}
        end
      end

      # Setting a Sencha proxy filter:
      #   "feed" returns photos belonging to followed users or named locations
      #   "category_id" returns photos belonging to specified category (1=fashion 2=place 3=art)
      #
      # "search_string" parameter performs full text search on photos
      # "location_google_id" parameter returns photos belonging in the specified location

      # all requests are paginated based on "page" and "limit" params and sorted according to the algorithm
      #
      # http://localhost:3000/api/v1/photos?utf8=%E2%9C%93&category_id=1&page=1&user_latitude=52.488909&user_longitude=13.421728
      # TODO This method is a mess, split it
      def index
        # update current user location, if coordinates not empty
        current_user.update_location(params[:user_latitude], params[:user_longitude])

        # time_factor
        # distance_factor

        time_factor = PhotoSearch.time_factor_from_param params[:time_factor]
        distance_factor = PhotoSearch.distance_factor_from_param params[:distance_factor]

        if params[:filter]
          @filter_params = HashWithIndifferentAccess.new
          @filter = ActiveSupport::JSON.decode(params[:filter])
          @filter_params[@filter[0].values[0]] = @filter[0].values[1]
          if @filter_params[:feed]
            params[:feed] = @filter_params[:feed]
          end
          if @filter_params[:category_id]
            params[:category_id] = @filter_params[:category_id]
          end
          if @filter_params[:location_google_id]
            params[:location_google_id] = @filter_params[:location_google_id]
          end
          if @filter_params[:user_id]
            params[:user_id] = @filter_params[:user_id]
          end
        end

        if !params[:user_id].nil?
          @search = PhotoSearch.user_photos( params[:user_id], params[:page], params[:limit])
        elsif !params[:feed].blank?
          @search = PhotoSearch.user_feed(current_user, params[:page], params[:limit])
        else

          @search = Sunspot.search (Photo) do
            # eager load user and named_location of each photo, to avoid N+1 queries
            data_accessor_for(Photo).include = [:user, :named_location]

            if !params[:search_string].blank?
              fulltext params[:search_string]
            end
            if !params[:category_id].nil?
              with(:category_id,  params[:category_id])
            end
            if !params[:location_google_id].nil?
              location = NamedLocation.find_by_google_id(params[:location_google_id])
              unless location.nil?
                with(:named_location_id, location.id)
              else
                # if the location is not found, just return an empty set
                with(:user_id).equal_to(nil)
              end
            end

            if !params[:page].blank?
              paginate(:page => params[:page], :per_page => params[:limit])
              Rails.logger.debug "User latitude before rounding: #{params[:user_latitude]}, after: #{params[:user_latitude].to_f.round(4)}"
              Rails.logger.debug "User longitude before rounding: #{params[:user_longitude]}, after: #{params[:user_longitude].to_f.round(4)}"
              adjust_solr_params do |solr_params|

                #Points = (clicks + 1) * exp(c1 * distance) * exp(c2 * time)
                #
                #c1 and c2 are negative constants.
                #Distance is the distance between the current location and the picture
                #time the time between the current time and the time the picture was taken.
                #Clicks is the amount of "so berlin" votes the photo has received
                #
                #The constants are:
                #c1 = -7e-4
                #c2 = -1.15e-09
                #Assuming distance in km for c1 and milliseconds for c2.

                # using reduced precision on time to prevent excessive memory consumption
                # also using reduced precision 4 decimals on geolocation coordinates
                solr_params[:sort] = "product(
                                        sum(plusminus_i,1),
                                        1.0e10,
                                        max(
                                          product(
                                            exp(
                                              product(
                                                #{distance_factor},
                                                geodist(
                                                  coordinates_ll,
                                                  #{params[:user_latitude].to_f.round(4)},
                                                  #{params[:user_longitude].to_f.round(4)}
                                                )
                                              )
                                            ),
                                            exp(
                                              product(
                                                #{time_factor},
                                                ms(NOW/HOUR, created_at_dt)
                                              )
                                            )
                                          ),
                                          1.0e-200
                                        )
                                     ) desc".gsub(/\s+/, " ").strip
              end

            end
          end
        end

        @photos = @search.results
        # set current_user on all photos before calling voted_by_current_user
        @photos.each { |photo|
          photo.current_user = current_user
        }
        if !params[:location_google_id].nil?
          location_followed_by_current_user = false
          location_google_id = nil
          location_reference = nil
          location = NamedLocation.find_by_google_id params[:location_google_id]
          unless location.nil?
            location.current_user = current_user
            location_followed_by_current_user = location.followed_by_current_user
            location_google_id = location.google_id
            location_reference = location.reference
          end

          render :json =>  { :records => @photos.map{|photo| photo.as_json}, :total_count => @search.total, :location_followed_by_current_user => location_followed_by_current_user, :location_google_id => location_google_id, :location_reference => location_reference}
        else
          render :json =>  { :records => @photos.map{|photo| photo.as_json}, :total_count => @search.total }
        end
      end

      # GET /photos/1
      # GET /photos/1.json
      def show
        photo = (Photo.find(params[:id]))
        # set current_user on all photos before calling voted_by_current_user
        photo.current_user = current_user
        render :json =>  { :records => [ photo ] }
      end

      # GET /photos/new
      # GET /photos/new.json
      def new
        photo = Photo.new

        # set current_user on all photos before calling voted_by_current_user
        photo.current_user = current_user
        render :json =>  { :records => [ photo ]}
      end

      # GET /photos/1/edit
      def edit
        @photo = Photo.find(params[:id])
      end

      # POST /photos
      # POST /photos.json
      def create

        # creating a photo with location_google_id will try to create the location
        # this is the only place where a new location can be created
        unless params[:location_google_id].nil? or params[:location_google_id].blank?
          named_location = NamedLocation.where(:google_id => params[:location_google_id]).first_or_create( :reference => params[:location_reference], :latitude => params[:latitude], :longitude => params[:longitude], :name => params[:location_name], :vicinity => params[:location_vicinity])
          params[:named_location_id] = named_location.id
        end

        params[:photo] = params.reject{|key, value| key.in?(["_method","authenticity_token","commit","auth_token","action","controller","format", "location_reference", "location_vicinity", "location_google_id", "location_name"])}


        photo = Photo.new(params[:photo])

        if photo.latitude.blank? or photo.latitude.nil?
          photo.show_on_map=false
        end

        unless params[:category_id].nil?
          photo.category_id = params[:category_id]
        end

        photo.user = current_user
        photo.current_user = current_user

        if photo.save
          render json: {:id => photo.id}, :status => :created
        else
          # phonegap fileuploader cannot handle data on failure, so the status is ok, although it has actually failed
          render :json => { :errors =>photo.errors },:status=> :ok
        end

      end

      # PUT /photos/1
      # PUT /photos/1.json
      def update
        photo = Photo.find(params[:id])
        photo.current_user = current_user
        if photo.update_attributes(params[:photo])
          render json: photo, status: :updated
        else
          render json: photo.errors, status: :unprocessable_entity
        end

      end

      # DELETE /photos/1
      # DELETE /photos/1.json
      def destroy
        photo = Photo.find(params[:id])
        photo.destroy
        render json: [ {notice: 'Photo was successfully deleted.' }  ]
      end

      def vote_up
        begin
          photo = Photo.find(params[:id])
          current_user.vote_for(photo)
          Sunspot.index! photo
          render json: [ {notice: 'Photo was successfully voted.' }  ]
        rescue ActiveRecord::RecordInvalid
          render json: [ {notice: 'Photo was not voted.' }  ] , status: :unprocessable_entity
        end
      end

      def report
          report = PhotoReport.where("user_id = ? AND photo_id = ?", current_user.id,params[:id] )
          if !report.empty?
            render json: [ {notice: 'You have already reported this photo.' }  ] , status: :unprocessable_entity
          else
            photo = Photo.find(params[:id])
            report = PhotoReport.create(:photo_id => photo.id, :user_id => current_user.id)
            if report.save
              # email all admin users
              AdminMailer.photo_reported_email(photo, current_user).deliver
              render json: [ {notice: 'Photo was successfully reported.' }  ]
            else
              render json: [ {notice: 'Photo was not reported, an error occured. Please contact the site admin' }  ] , status: :unprocessable_entity

            end
          end
      end
    end
  end
end
