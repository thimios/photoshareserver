class UsersController < ApplicationController
  before_filter :my_authenticate_user
  respond_to :html
  load_and_authorize_resource
  layout "admin"


  # GET /admin/users
  def index

    @users = User.page(params[:page]).per(params[:limit])

    # set current_user on all photos before calling voted_by_current_user
    @users.each { |item|
      item.current_user = current_user
    }

  end

end
