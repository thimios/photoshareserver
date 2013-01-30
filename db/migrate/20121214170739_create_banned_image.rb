class CreateBannedImage < ActiveRecord::Migration
  def up
    bannedimagefile = File.open(File.join(Rails.root, 'app', 'assets','images','bannedphoto.png'))
    photo = SystemPhoto.find_by_title "banned image"
    if photo.nil?
      photo = SystemPhoto.create(title: "banned image", image: bannedimagefile)
      photo.save
    end
  end

  def down
  end
end
