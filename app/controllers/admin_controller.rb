class AdminController < ApplicationController
  layout "admin"
  skip_authorization_check

  def home
     unless user_signed_in?
       redirect_to login_path
     end
  end

end