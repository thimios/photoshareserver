class GiveAdminToSpirosThimios < ActiveRecord::Migration
  def up
    thimios = User.find_by_email("thimios@wantedpixel.com")
    thimios.admin=true
    thimios.superadmin=true
    thimios.save

    spiros = User.find_by_email("spiros@wantedpixel.com")
    spiros.admin=true
    spiros.superadmin=true
    spiros.save
  end

  def down
  end
end
