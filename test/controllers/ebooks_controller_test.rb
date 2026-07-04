require "test_helper"

class EbooksControllerTest < ActionDispatch::IntegrationTest
  test "should get download" do
    get ebooks_download_url
    assert_response :success
  end
end
