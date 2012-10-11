class PhotosController < ApplicationController
  before_filter :authenticate_user!

  # GET /photos
  # GET /photos.json
  def index
    if params[:category_id].nil? and params[:search_string].blank?
      @photos = Photo.all
    else
      @search = Sunspot.search (Photo) do
        if !params[:search_string].blank?
          fulltext params[:search_string]
        end
        if !params[:category_id].nil?
          with(:category_id,  params[:category_id])
        end

        order_by_geodist :coordinates, current_user.latitude, current_user.longitude, :asc
      end
      @photos = @search.results
    end

    @photos.each { |photo|

      # add whether the current user has voted for it
      if (current_user.voted_against?(photo))
        photo["voted_by_current_user"] = "against"
      elsif (current_user.voted_for?(photo))
        photo["voted_by_current_user"] = "for"
      else
        photo["voted_by_current_user"] = "not"
      end

      # also add plusminus
      photo["plusminus"] = photo.plusminus

    }
    @googleMapsJson = @photos.to_gmaps4rails do |photo, marker|
        marker.title   photo.title
        marker.infowindow photo.address
    end

    respond_to do |format|
      format.html {@googleMapsJson }# index.html.erb
      format.json { render json: @photos,  methods: [:full_size_url, :medium_size_url, :thumb_size_url] }
    end
  end

  # GET /photos/1
  # GET /photos/1.json
  def show
    @photo = Photo.find(params[:id])

    if (current_user.voted_against?(@photo))
      @photo["voted_by_current_user"] = "against"
    elsif (current_user.voted_for?(@photo))
      @photo["voted_by_current_user"] = "for"
    else
      @photo["voted_by_current_user"] = "not"
    end

    # also add plusminus
    @photo["plusminus"] = @photo.plusminus

    respond_to do |format|
      format.html { @googleMapsJson = @photo.to_gmaps4rails }# show.html.erb
      format.json { render json: @photo, methods:[:full_size_url, :medium_size_url, :thumb_size_url] }
    end
  end

  # GET /photos/new
  # GET /photos/new.json
  def new
    @photo = Photo.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @photo, methods:[:full_size_url, :medium_size_url, :thumb_size_url] }
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
