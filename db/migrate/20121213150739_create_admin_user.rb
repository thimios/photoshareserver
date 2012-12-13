class CreateAdminUser < ActiveRecord::Migration
  def up
    imagefile = File.open(File.join(Rails.root, 'test', 'fixtures','seed.jpg'))
    user3 =
        User.find_or_create_by_email(
            :username => "soberlin",
            :birth_date => "2010-09-28 00:00:00",
            :gender => "male",
            :email => "info.soberlin@gmail.com",
            :password => 'Bernvero1',
            :password_confirmation => 'Bernvero1',
            :address => 'Schlegelstrasse 15, 10115 Berlin, Germany',
            :avatar => imagefile,
            :admin => true,
            :superadmin => false
        )
    user3.confirm!
    user3.geocode
    user3.save
  end

  def down
  end
end
