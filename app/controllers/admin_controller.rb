class AdminController < ApplicationController
  layout "admin"
  skip_authorization_check

  def home

  end

end