require "test_helper"

class SignInFlowTest < ActionDispatch::IntegrationTest
  test "can sign in with a confirmed user" do
    two = users(:two) # User with a confirmed email
    post login_path, params: { user: { email: two.email, password: "PasswordTwo" } }

    assert_response :redirect, to: root_path
    follow_redirect!
    assert_includes flash[:notice], "Signed in"
  end

  test "should not be able to access auth routes after successful login" do
    get login_path
    assert_response :success
    assert_equal 200, status

    two = users(:two)
    post login_path, params: { user: { email: two.email, password: "PasswordTwo" } }

    get login_path
    assert_response :redirect, alert: "You are already logged in"
  end

  test "should render generic error if credentials are wrong" do
    post login_path, params: { user: { email: "incorrect@email.com", password: "PasswordOne" } }

    assert_response :unprocessable_entity, alert: "Incorrect email or password"
  end

  test "should not sign in if user has not confirmed his email" do
    one = users(:one)
    post login_path, params: { user: { email: one.email, password: "PasswordOne" } }

    assert_response :redirect, alert: "Incorrect email or password"
    follow_redirect!
    assert_equal new_confirmation_path, path
  end
end
