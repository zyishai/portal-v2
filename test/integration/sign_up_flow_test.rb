require "test_helper"

class SignUpFlowTest < ActionDispatch::IntegrationTest
  setup do
    @sign_up_params = { user: { email: "sign_up_flow@example.com", password: "123", password_confirmation: "123" } }
  end

  test "can create a new user" do
    post sign_up_path, params: @sign_up_params
    new_user = User.find_by(email: @sign_up_params[:user][:email])

    assert_not_nil new_user
  end

  test "should notify the user after successful sign up" do
    post sign_up_path, params: @sign_up_params
    assert_response :redirect
    follow_redirect!

    assert_includes flash[:notice], "check your email for confirmation instructions"
  end

  test "send confirmation email after successful sign up" do
    emails = capture_emails do
      post sign_up_path, params: @sign_up_params
    end

    assert_equal emails.length, 1
    assert_includes emails.first.to, @sign_up_params[:user][:email]
    assert_includes emails.first.subject, "Confirmation Instructions"
  end

  test "fails when password confirmation not matching password" do
    post sign_up_path, params: { user: { email: "foo@example.com", password: "123", password_confirmation: "1234" } }
    assert_response :unprocessable_entity
  end

  test "fails when email is missing" do
    post sign_up_path, params: { user: { password: "123", password_confirmation: "123" } }
    assert_response :unprocessable_entity
  end
end
