class HomeController < ApplicationController
  layout "frontend",  :except => [:launchrock]
  require_dependency 'photo_search'

  skip_authorization_check


  def launchrock
    # launchrock.html.erb
  end

  def photos_paging
    params[:page] = params[:page] || 1
    case params["show"]
      when "fashion"
        @photos = PhotoSearch.category_created_at(1, params[:page], 24)
        @active = "fashion"
      when "places"
        @photos = PhotoSearch.category_created_at(2, params[:page], 24)
        @active = "places"
      when "design"
        @photos = PhotoSearch.category_created_at(3, params[:page], 24)
        @active = "design"
      when "best"
        @photos = PhotoSearch.best(params[:page], 24)
        @active = "best"
      else
        @photos = PhotoSearch.all(params[:page],24)
        @active = "all"
    end
    render @photos
  end

  def home_photo_detail
    params[:page] = params[:page] || 1
    @detailsview_id = params[:id]
    @photos = PhotoSearch.all(params[:page],24)
    @active = "all"

    # home.html.erb
    render 'home'
  end

  def home

    case params["show"]
      when "fashion"
        @photos = PhotoSearch.category_created_at(1, params[:page], 24)
        @active = "fashion"
      when "places"
        @photos = PhotoSearch.category_created_at(2, params[:page], 24)
        @active = "places"
      when "design"
        @photos = PhotoSearch.category_created_at(3, params[:page], 24)
        @active = "design"
      when "best"
        @photos = PhotoSearch.best(params[:page], 24)
        @active = "best"
      else
        @photos = PhotoSearch.all(params[:page],24)
        @active = "all"
    end
  end

  def photo_details
    #photo_details.html.erb
    @photo = Photo.includes(:user, :comments).find(params[:id])
    @commentsleft = @photo.comments.page(1).per(4)
    @commentsright = @photo.comments.page(2).per(4)
    render :layout => 'empty'

  end

  def contact
    # contact.html.erb
  end

  def press
    # press.html.erb
  end

  def about
    # about.html.erb
  end

  def terms
    # terms.html.erb
  end

end
