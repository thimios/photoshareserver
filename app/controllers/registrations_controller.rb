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
end