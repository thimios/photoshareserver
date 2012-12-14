class CreateBannedImage < ActiveRecord::Migration
  def up
    bannedimagefile = File.open(File.join(Rails.root, 'app', 'assets','images','bannedphoto.png'))
    SystemPhoto.create(title: "banned image", image: bannedimagefile)
  end

  def down
  end
end
