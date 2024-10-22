require "test_helper"

class LogoutFlowTest < ActionDispatch::IntegrationTest
  test "should redirect to the root path after logging out" do
    delete logout_path

    assert_response :redirect, to: root_path, notice: "Signed out"
  end

  test "should be able to access login page after successfull logout" do
    two = users(:two)
    post login_path, params: { user: { email: two.email, password: "PasswordTwo" } }

    get login_path
    assert_response :redirect, to: root_path

    delete logout_path
    follow_redirect!

    get login_path
    assert_response :success
  end
end
