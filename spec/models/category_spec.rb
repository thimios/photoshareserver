require 'rails_helper'

RSpec.describe Category, :type => :model do
  it "should validate presence of title" do
    expect(subject).to validate_presence_of :title
  end
end