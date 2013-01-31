class CreateDefaultAvatarImage < ActiveRecord::Migration
  def up
    imagefile = File.open(File.join(Rails.root, 'app', 'assets','images','defaultavatar.png'))
    photo = SystemPhoto.find_by_title "default avatar"
    if photo.nil?
      photo = SystemPhoto.create(title: "default avatar", image: imagefile)
      photo.save
    end
  end

  def down
  end
end
