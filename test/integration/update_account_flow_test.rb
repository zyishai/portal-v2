require "test_helper"

class UpdateAccountFlowTest < ActionDispatch::IntegrationTest
  test "can update password" do
    user = users(:three)
    old_password_digest = user.password_digest

    login(email: user.email, password: "PasswordThree")
    put account_path, params: { user: { current_password: "PasswordThree", password: "NewPassword", password_confirmation: "NewPassword" } }

    assert_response :redirect
    follow_redirect!

    assert_equal root_path, path
    assert_includes flash[:notice], "Account updated"

    user.reload

    assert_not_equal user.password_digest, old_password_digest
  end

  test "send confirmation email when updating email" do
    user = users(:three)

    login(email: user.email, password: "PasswordThree")

    assert_emails 1 do
      put account_path, params: { user: { current_password: "PasswordThree", unconfirmed_email: "new_email@example.com" } }
    end
  end

  test "does not update email until confirmated" do
    user = users(:three)
    old_email = user.email

    login(email: user.email, password: "PasswordThree")
    emails = capture_emails do
      put account_path, params: { user: { current_password: "PasswordThree", unconfirmed_email: "new_email@example.com" } }
    end
    user.reload

    assert_equal old_email, user.email

    confirmation_link = email_link(emails.first, "Click here to confirm your email")

    get confirmation_link
    user.reload

    assert_equal "new_email@example.com", user.email
  end
end
