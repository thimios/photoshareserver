require 'rails_helper'
include Devise::TestHelpers
include Api::V1

describe NamedLocationsController, :type => :controller do
  login_user

  it "should have a current_user" do
    expect(subject.current_user).to_not be_nil
  end

end

