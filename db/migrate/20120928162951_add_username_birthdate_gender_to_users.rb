class AddUsernameBirthdateGenderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :birth_date, :datetime
    add_column :users, :gender, :string
  end
end
