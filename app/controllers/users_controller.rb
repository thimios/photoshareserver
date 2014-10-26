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
    send_data @users.to_web_csv, :filename => 'users.csv'
  end

  def show
    @user = User.find(params[:id])
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  def generate_new_password_email
    user = User.find(params[:user_id])
    user.send_reset_password_instructions
    redirect_to edit_user_url(user), :notice => "Reset password instructions have been sent to #{user.email}."
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to edit_user_url(@user), :notice => 'User was successfully updated.'
    else
      render action: "edit"
    end
  end

end
