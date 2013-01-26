require 'test_helper'

class PhotoReportTest < ActiveSupport::TestCase
  fixtures :categories, :users, :photos, :photo_reports
  test "report belonging to photo" do
    photo = Photo.find 1
    report = PhotoReport.find 1
    assert_equal 1, photo.photo_reports.count
  end
end
