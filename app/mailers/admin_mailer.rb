class AdminMailer < ActionMailer::Base
  default :to => User.where("admin = ?", true).map(&:email),
          :from => "no-reply@soberlin.org"

  def photo_reported_email(photo, user)
    @user = user
    @photo = photo
    @admin_url  = admin_url
    mail(:subject => "User: #{user.username} reported a photo on So Berlin!")
  end


end
