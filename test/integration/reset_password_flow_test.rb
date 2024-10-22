require "test_helper"

class ResetPasswordFlowTest < ActionDispatch::IntegrationTest
  test "should not send password reset instructions email if user is not confirmed" do
    user = users(:one)
    assert user.unconfirmed?

    post passwords_path, params: { user: { email: user.email } }
    assert_response :redirect, to: new_confirmation_path, alert: "confirm your email first"
  end

  test "should send a password reset instructions email if user exists" do
    user = users(:three)
    assert user.confirmed?

    emails = capture_emails do
      post passwords_path, params: { user: { email: user.email } }
    end

    assert_response :redirect
    follow_redirect!
    assert_equal root_path, path
    assert_includes flash[:notice], "If that user exists we've sent instructions to their email"

    assert_equal 1, emails.length
    assert_includes emails.first.to, user.email
  end

  test "should render a generic response if user doesn't exist" do
    assert_emails 0 do
      post passwords_path, params: { user: { email: "fake@example.com" } }
    end

    assert_response :redirect
    follow_redirect!
    assert_equal root_path, path
    assert_includes flash[:notice], "If that user exists we've sent instructions to their email"
  end

  test "accept valid reset token" do
    user = users(:three)
    token = user.generate_password_reset_token

    get edit_password_path(password_reset_token: token)
    assert_response :success
  end

  test "should deny expired token" do
    expiration = User::PASSWORD_RESET_TOKEN_EXPIRATION
    User.const_set(:PASSWORD_RESET_TOKEN_EXPIRATION, 0.seconds)

    user = users(:three)
    token = user.generate_password_reset_token

    get edit_password_path(password_reset_token: token)
    assert_response :redirect
    follow_redirect!

    assert_equal new_password_path, path
    assert_includes flash[:alert], "Invalid or expired token"

    User.const_set(:PASSWORD_RESET_TOKEN_EXPIRATION, expiration)
  end

  test "should deny valid token for unconfirmed user" do
    user = users(:one)
    assert user.unconfirmed?

    token = user.generate_password_reset_token

    get edit_password_path(password_reset_token: token)
    assert_response :redirect
    follow_redirect!

    assert_equal new_confirmation_path, path
    assert_includes flash[:alert], "You must confirm your email before you can sign in"
  end

  test "can update password" do
    user = users(:three)
    old_password_digest = user.password_digest
    token = user.generate_password_reset_token

    put password_path(password_reset_token: token), params: { user: { password: "NewPassword", password_confirmation: "NewPassword" } }

    assert_response :redirect
    follow_redirect!
    assert_equal login_path, path
    assert_includes flash[:notice], "Sign in"

    user.reload

    assert_not_equal old_password_digest, user.password_digest
  end

  test "should not update password for unconfirmed user" do
    user = users(:one)
    token = user.generate_password_reset_token

    put password_path(password_reset_token: token), params: { user: { password: "s3cr3t", password_confirmation: "s3cr3t" } }

    assert_response :redirect
    follow_redirect!

    assert_equal new_confirmation_path, path
    assert_includes flash[:alert], "You must confirm your email before you can sign in"
  end

  test "should not update password if token is expired" do
    expiration = User::PASSWORD_RESET_TOKEN_EXPIRATION
    User.const_set(:PASSWORD_RESET_TOKEN_EXPIRATION, 0.seconds)

    user = users(:two)
    token = user.generate_password_reset_token
    put password_path(password_reset_token: token), params: { user: { password: "s3cr3t", password_confirmation: "s3cr3t" } }

    assert_response :unprocessable_entity
    assert_includes flash[:alert], "Invalid or expired token"

    User.const_set(:PASSWORD_RESET_TOKEN_EXPIRATION, expiration)
  end

  test "should not update if passwords don't match" do
    user = users(:two)
    token = user.generate_password_reset_token

    put password_path(password_reset_token: token), params: { user: { password: "123", password_confirmation: "1234" } }

    assert_response :unprocessable_entity
  end
end
