class RegistrationsController < Devise::RegistrationsController
  respond_to :json
  # GET /users
  # GET /users.json
  def index
    warden.authenticate!

    if params[:filter]
      @filter_params = HashWithIndifferentAccess.new
      @filter = ActiveSupport::JSON.decode(params[:filter])
      @filter_params[@filter[0].values[0]] = @filter[0].values[1]
      if @filter_params[:followed_by_current_user]
        params[:followed_by_current_user] = @filter_params[:followed_by_current_user]
      end
    end

    if params[:followed_by_current_user] == "true"
      @users = User.where(:id => current_user.all_following.map{|following_user| following_user.id}).page(params[:page]).per(params[:limit])
    elsif params[:search_string].blank?
      @users = User.page(params[:page]).per(params[:limit])
      @total_count = @users.total_count
    else
      @search = Sunspot.search (User) do
        if !params[:search_string].blank?
          fulltext params[:search_string]
        end

        if !params[:page].blank?
          paginate(:page => params[:page], :per_page => params[:limit])
        end
      end
      @users = User.find(@search.results.map{|user| user.id})
      @total_count = @search.total
    end

    # set current_user on all users before calling voted_by_current_user
    @users.each { |user|
      user.current_user = current_user
    }

    respond_to do |format|
      format.html # index.html.erb
      format.json {
        @records_as_json = @users.as_json( :except => [:email, :address,:longitude, :latitude, :gender, :birth_date ] )
        render :json =>  { :records => @records_as_json, :total_count => @total_count }
      }
    end
  end

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

    @users[0] = @user

    # set current_user on all users before calling voted_by_current_user
    @users.each { |user|
      user.current_user = current_user
    }
    respond_to do |format|
      format.html # show.html.erb
      format.json {
        unless params[:id].eql? (current_user.id.to_s)
          @records_as_json = @users.as_json( :except => [:email, :address,:longitude, :latitude, :gender, :birth_date ] )
        else
          @records_as_json = @users.as_json()
        end
        render json: @records_as_json
      }
    end
  end

  def follow
    warden.authenticate!
    @user = User.find(params[:id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to "/users/#{@user.id}", notice: 'You are now following '+@user.username }
      format.json { render json: [notice: 'You are now following '+@user.username], status: 200}
    end
  end

  def unfollow
    warden.authenticate!
    @user = User.find(params[:id])
    current_user.stop_following(@user)
    respond_to do |format|
      format.html { redirect_to "/users/#{@user.id}", notice: 'You are not following '+@user.username + " any more." }
      format.json { render  json: [ notice => 'You are not following '+@user.username + " any more."  ], status: 200}
    end
  end



end