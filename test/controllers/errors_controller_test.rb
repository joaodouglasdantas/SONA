require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should get routing" do
    get errors_routing_url
    assert_response :success
  end
end
