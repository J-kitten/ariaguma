require "test_helper"

class ManagementScreen::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get management_screen_dashboard_index_url
    assert_response :success
  end
end
