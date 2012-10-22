class PhotosController < ApplicationController
  before_filter :authenticate_user!


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
        render :json =>  { :records => @photos }
      }
    end
  end

  # GET /photos
  # GET /photos.json
  def index
    if params[:filter]
      @filter_params = HashWithIndifferentAccess.new
      @filter = ActiveSupport::JSON.decode(params[:filter])
      @filter_params[@filter[0].values[0]] = @filter[0].values[1]
      if @filter_params[:category_id]
        params[:category_id] = @filter_params[:category_id]
      end
    end

    if params[:category_id].nil? and params[:search_string].blank?
      @photos = Photo.page(params[:page]).per(params[:limit])
      @total = @photos.total_count
    else
      @search = Sunspot.search (Photo) do
        if !params[:search_string].blank?
          fulltext params[:search_string]
        end
        if !params[:category_id].nil?
          with(:category_id,  params[:category_id])
        end
        if !params[:page].blank?
          paginate(:page => params[:page], :per_page => params[:limit])
          order_by_geodist :coordinates, current_user.latitude, current_user.longitude, :asc
        end
        if (params[:sw_y] && params[:sw_x] && params[:ne_y] && params[:ne_x])
          with(:coordinates).in_bounding_box([params[:sw_y], params[:sw_x]], [params[:ne_y], params[:ne_x]])
        end
      end
      @photos = Photo.find(@search.results.map{|photo| photo.id})
      @total = @search.total
    end

    @googleMapsJson = @photos.to_gmaps4rails do |photo, marker|
      marker.title   photo.title
      marker.infowindow photo.address
    end

    # set current_user on all photos before calling voted_by_current_user
    @photos.each { |photo|
      photo.current_user = current_user
    }

    respond_to do |format|
      format.html {@googleMapsJson }# index.html.erb
      format.json {
        render :json =>  { :records => @photos.as_json, :total_count => @total }
      }
    end
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
    @photos = Array.new
    @photo = (Photo.find(params[:id]))

    # set current_user on all photos before calling voted_by_current_user
    @photo.current_user = current_user
    @photos[0] = @photo
    respond_to do |format|
      format.html { @googleMapsJson = @photo.to_gmaps4rails }# show.html.erb
      format.json {
        render :json =>  { :records => @photos }
      }
    end
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = Photo.new

    # set current_user on all photos before calling voted_by_current_user
    @photo.current_user = current_user

    respond_to do |format|
      format.html # new.html.erb
      format.json {
        render :json =>  { :records => @photos}
      }
    end
  end

  # GET /photos/1/edit
  def edit
    @photo = Photo.find(params[:id])
  end

  # POST /photos
  # POST /photos.json
  def create
    @photo = Photo.new(params[:photo])
    unless params[:category_id].nil?
      @photo.category_id = params[:category_id]
    end
    
    respond_to do |format|
      if @photo.save
        format.html { redirect_to @photo, notice: 'Photo was successfully created.' }
        format.json { render json: @photo, status: :created}
      else
        format.html { render action: "new" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /photos/1
  # PUT /photos/1.json
  def update
    @photo = Photo.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        format.html { redirect_to @photo, notice: 'Photo was successfully updated.' }
        format.json { render json: @photo, status: :updated  }
      else
        format.html { render action: "edit" }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to photos_url }
      format.json { head :no_content }
    end
  end

  def vote_up
    begin
      @photo = Photo.find(params[:id])
      current_user.vote_for(@photo)
      respond_to do |format|
        format.html { redirect_to @photo, notice: 'Photo was successfully voted.' }
        format.json { render json: @photo, status: 200}
      end
    rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        format.html { redirect_to @photo, notice: 'Photo was not voted.'}
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end

  end

end
