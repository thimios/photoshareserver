class UsersController < ApplicationController
  before_filter :my_authenticate_user
  respond_to :html
  load_and_authorize_resource
  layout "admin"

  require_dependency 'user_search'

  def search
    @users = UserSearch.fulltext(params[:search_string], params[:page], params[:limit])
    render "index"
  end

  # GET /admin/users
  def index
    @users = User.page(params[:page]).per(params[:limit])

    # set current_user on all photos before calling voted_by_current_user
    @users.each { |item|
      item.current_user = current_user
    }
  end

  def csv
    @users = User.order(:username)
    send_data @users.to_web_csv, :filename => 'soberlin-users.csv'
  end

  def show
    @user = User.find(params[:id])
  end

end
