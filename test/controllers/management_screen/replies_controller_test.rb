require "test_helper"

class ManagementScreen::RepliesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get management_screen_replies_show_url
    assert_response :success
  end
end
