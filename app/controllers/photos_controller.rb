class PhotosController < ApplicationController
  before_filter :my_authenticate_user
  respond_to :html
  load_and_authorize_resource
  layout "admin"
  require_dependency 'photo_search'

  # GET /photos
  def index
    @photos = PhotoSearch.reported.page(params[:page]).per(params[:limit])
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

  def destroy_all_reported
    Photo.where("photo_reports_count > 0").find_each do |photo|
      photo.destroy
    end
    redirect_to photos_url
  end

  def ban_all_reported
    Photo.where("photo_reports_count > 0").find_each do |photo|
      photo.banned=true
      photo.save
    end
    redirect_to photos_url
  end

  # DELETE /photos/1
  # DELETE /photos/1.json
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    redirect_to photos_url
  end

  def toggle_ban
    photo = Photo.find(params[:id])
    unless photo.banned?
      photo.banned=true
      photo.save
      redirect_to :back, notice: 'Photo was successfully banned.'
    else
      photo.banned=false
      photo.save
      redirect_to :back, notice: 'Photo was successfully unbanned.'
    end
  end

  def refuse_ban
    reports = PhotoReport.where(:photo_id => params[:id])
    reports.each { |report|
      report.destroy
    }
    redirect_to @photo, notice: 'All reports of this photo have been successfully deleted.'
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
