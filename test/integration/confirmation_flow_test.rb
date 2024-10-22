require "test_helper"

class ConfirmationFlowTest < ActionDispatch::IntegrationTest
  test "can confirm a user's email" do
    one = users(:one)
    assert one.unconfirmed?

    token = one.generate_confirmation_token

    get edit_confirmation_path(confirmation_token: token)

    assert_response :redirect, to: root_path, notice: "Your account has been confirmed"
    follow_redirect!

    one.reload
    assert one.confirmed?
  end

  test "should not confirm with expired token" do
    expiration = User::CONFIRMATION_TOKEN_EXPIRATION
    User.const_set(:CONFIRMATION_TOKEN_EXPIRATION, 0.seconds)

    one = users(:one)
    assert one.unconfirmed?

    token = one.generate_confirmation_token

    get edit_confirmation_path(confirmation_token: token)

    assert_response :redirect, to: new_confirmation_path, alert: "Invalid token"
    follow_redirect!

    one.reload
    assert one.unconfirmed?
    User.const_set(:CONFIRMATION_TOKEN_EXPIRATION, expiration)
  end

  test "should not confirm an already confirmed user" do
    three = users(:three)
    assert three.confirmed?

    token = three.generate_confirmation_token
    get edit_confirmation_path(confirmation_token: token)

    assert_response :redirect
    follow_redirect!

    assert_equal new_confirmation_path, path
    assert_includes flash[:alert], "Invalid token"
  end

  test "should confirm when a user changes its email" do
    two = users(:two)
    assert two.confirmed?
    assert two.reconfirming?
    new_email = two.unconfirmed_email

    token = two.generate_confirmation_token
    get edit_confirmation_path(confirmation_token: token)

    assert_response :redirect
    follow_redirect!

    assert_equal root_path, path
    assert_includes flash[:notice], "Your account has been confirmed"

    two.reload

    assert_nil two.unconfirmed_email
    assert_not two.reconfirming?
    assert_equal two.email, new_email
  end
end
