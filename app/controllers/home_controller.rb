class HomeController < ApplicationController
  layout "frontend",  :except => [:launchrock]
  require_dependency 'photo_search'

  def launchrock
    # launchrock.html.erb
  end

  def home
    # home.html.erb
    @photos = PhotoSearch.category_created_at(1, 1, 30)

    @photos


  end

  def facebook
    # facebookq.html.erb
  end

end
