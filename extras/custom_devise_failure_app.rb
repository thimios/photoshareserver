class CustomDeviseFailureApp < Devise::FailureApp
  def redirect_url
    "/login"
  end
end