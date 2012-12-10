class HomeController < ApplicationController
  layout "frontend",  :except => [:launchrock]
  require_dependency 'photo_search'

  def launchrock
    # launchrock.html.erb
  end

  def home
    # home.html.erb

    case params["show"]
      when "fashion"
        @photos = PhotoSearch.category_created_at(1, 1, 24)
        @active = "fashion"
      when "places"
        @photos = PhotoSearch.category_created_at(2, 1, 24)
        @active = "places"
      when "design"
        @photos = PhotoSearch.category_created_at(3, 1, 24)
        @active = "design"
      when "best"
        @photos = PhotoSearch.best(1, 24)
        @active = "best"
      else
        @photos = PhotoSearch.all(1,24)
        @active = "all"
    end
  end

  def facebook
    # facebook.html.erb
  end

  def about
    # about.html.erb
  end

  def about
    # terms.html.erb
  end

end
