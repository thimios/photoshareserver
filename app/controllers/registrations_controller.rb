class RegistrationsController < Devise::RegistrationsController

 # respond_to :json
  def create

    user = User.new(params[:registration])
    if user.save
      render :json=> user.as_json(:auth_token=>user.authentication_token, :email=>user.email), :status=>201
      return
    else
      warden.custom_failure!
      render :json => { :errors =>user.errors },:status=>422
    end
  end

  # GET /users/1
  # GET /users/1.json
  # Show user's public profile
  def show
    warden.authenticate!
    @users = Array.new
    @user = (User.find(params[:id]))

    @activities = PublicActivity::Activity.where(:owner_id =>params[:id])

    # set current_user on all photos before calling voted_by_current_user
    @users[0] = @user
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @users }
    end
  end
end