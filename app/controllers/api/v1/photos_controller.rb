module Api
  module V1

    class PhotosController < ApplicationController
      before_filter :my_authenticate_user
      # the api is always available to all logged in users
      skip_authorization_check

      #http://localhost:3000/photos/indexbbox.json?sw_y=48.488334&sw_x=6.416342&ne_y=57.492658&ne_x=18.428616
      def indexbbox
        @search = Sunspot.search (Photo) do
          with(:coordinates).in_bounding_box([params[:sw_y], params[:sw_x]], [params[:ne_y], params[:ne_x]])
        end
        @photos = Photo.find(@search.results.map{|photo| photo.id})
        #@googleMapsJson = @photos.to_gmaps4rails do |photo, marker|
        #  marker.title   photo.title
        #  marker.infowindow photo.address
        #end
        # set current_user on all photos before calling voted_by_current_user
        @photos.each { |photo|
          photo.current_user = current_user
        }
        respond_to do |format|
          format.html {@googleMapsJson }# index.html.erb
          format.json {
            render :json => @photos
          }
        end
      end

      # GET /photos
      # GET /photos.json
      # http://localhost:3000/api/v1/photos?utf8=%E2%9C%93&category_id=1&page=1&user_latitude=52.488909&user_longitude=13.421728
      def index
        # update current user location, if coordinates not empty
        current_user.update_location(params[:user_latitude], params[:user_longitude])

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
        end

        @search = Sunspot.search (Photo) do
          if !params[:search_string].blank?
            fulltext params[:search_string]
          end
          if !params[:category_id].nil?
            with(:category_id,  params[:category_id])
          end
          if !params[:location_google_id].nil?
            fulltext  params[:location_google_id]
          end
          if !params[:feed].blank?
            if current_user.following_users_count > 0
              with(:user_id).any_of(current_user.following_users.map{|followed_user| followed_user.id})
            else
              with(:user_id).equal_to(nil)
            end
          end
          if !params[:page].blank?
            paginate(:page => params[:page], :per_page => params[:limit])
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
              solr_params[:sort] = "product( sum(plusminus_i,1), exp( product(
                                         -7e-4,
                                          geodist(
                                            coordinates_ll,
                                            #{params[:user_latitude]},
                                            #{params[:user_longitude]}
                                          )
                                        )
                                      ),
                                      exp(
                                        product(
                                            -1.15e-09,
                                            ms(NOW, created_at_dt)
                                        )
                                      )
                                   ) desc".gsub(/\s+/, " ").strip
            end

          end
          if (params[:sw_y] && params[:sw_x] && params[:ne_y] && params[:ne_x])
            with(:coordinates).in_bounding_box([params[:sw_y], params[:sw_x]], [params[:ne_y], params[:ne_x]])
          end

        end

        @photos = @search.results

        # set current_user on all photos before calling voted_by_current_user
        @photos.each { |photo|
          photo.current_user = current_user
        }
        if !params[:location_google_id].nil?
          location_followed_by_current_user = false
          location = NamedLocation.find_by_google_id params[:location_google_id]
          unless location.nil?
            location.current_user = current_user
            location_followed_by_current_user = location.followed_by_current_user
          end

          render :json =>  { :records => @photos.map{|photo| photo.as_json}, :total_count => @search.total, :location_followed_by_current_user => location_followed_by_current_user, :location_google_id => location.google_id, :location_reference => location.reference}
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

        unless params[:location_google_id].nil? or params[:location_google_id].blank?
          named_location = NamedLocation.find_or_create_by_google_id params[:location_google_id], :reference => params[:location_reference], :latitude => params[:latitude], :longitude => params[:longitude]
          params[:named_location_id] = named_location.id
        end

        params[:photo] = params.reject{|key, value| key.in?(["_method","authenticity_token","commit","auth_token","action","controller","format", "location_reference"])}

        photo = Photo.new(params[:photo])
        unless params[:category_id].nil?
          photo.category_id = params[:category_id]
        end

        photo.user = current_user
        photo.current_user = current_user

        if photo.save
          render json: {:id => photo.id}, :status => :created
        else
          render :json => { :errors =>photo.errors },:status=> :ok #phonegap fileuploader cannot handle data on failure
        end

      end

      # PUT /photos/1
      # PUT /photos/1.json
      def update
        photo = Photo.find(params[:id])
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
