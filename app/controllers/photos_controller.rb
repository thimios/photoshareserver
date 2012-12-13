class PhotosController < ApplicationController
  before_filter :my_authenticate_user
  respond_to :html
  load_and_authorize_resource
  layout "admin"
  require_dependency 'photo_search'

  # GET /photos
  def index
    @search = Sunspot.search (Photo) do
      if !params[:search_string].blank?
        fulltext params[:search_string]
      end
      if !params[:category_id].nil?
        with(:category_id,  params[:category_id])
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
        order_by_geodist :coordinates, current_user.latitude, current_user.longitude, :asc
      end
      if (params[:sw_y] && params[:sw_x] && params[:ne_y] && params[:ne_x])
        with(:coordinates).in_bounding_box([params[:sw_y], params[:sw_x]], [params[:ne_y], params[:ne_x]])
      end
    end
    @photos = @search.results
    @googleMapsJson = @photos.to_gmaps4rails do |photo, marker|
      marker.title   photo.title
      marker.infowindow photo.address
    end
    # set current_user on all photos before calling voted_by_current_user
    @photos.each { |photo|
      photo.current_user = current_user
    }

  end

  # GET /photos/1

  def show
    @photo = (Photo.find(params[:id]))
    # set current_user on all photos before calling voted_by_current_user
    @photo.current_user = current_user
    @googleMapsJson = @photo.to_gmaps4rails # show.html.erb
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = Photo.new

    # set current_user on all photos before calling voted_by_current_user
    @photo.current_user = current_user
  end

  # GET /photos/1/edit
  def edit
    @photo = Photo.find(params[:id])
  end

  # POST /photos
  # POST /photos.json
  def create
    if !params[:photo].nil?
      @photo = Photo.new(params[:photo])
    else
      @photo = Photo.new(:title => params[:title], :description => params[:description], :category_id => params[:category_id], :address => params[:address], :image => params[:image]  )
    end
    unless params[:category_id].nil?
      @photo.category_id = params[:category_id]
    end

    @photo.user = current_user
    @photo.current_user = current_user
    if @photo.save
      redirect_to @photo, notice: 'Photo was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /photos/1
  def update
    @photo = Photo.find(params[:id])
    if @photo.update_attributes(params[:photo])
      redirect_to @photo, notice: 'Photo was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo = Photo.find(params[:id])
    logger.debug "no photos can be deleted"
    #@photo.destroy
    redirect_to photos_url
  end

  def vote_up
    begin
      @photo = Photo.find(params[:id])
      current_user.vote_for(@photo)
      redirect_to @photo, notice: 'Photo was successfully voted.'
    rescue ActiveRecord::RecordInvalid
      redirect_to @photo, notice: 'Photo was not voted.'
    end
  end
end
