require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user email must be a valid Email address" do
    one = users(:one)
    one.email = "foobar.com"
    one.valid?

    assert_includes one.errors.messages[:email], "is invalid"

    one.email = "one@example.com"
    assert_equal one.valid?, true
  end

  test "email is saved in small case letters" do
    two = users(:two)
    two.email = "TWO@EXAMPLE.COM"
    two.save

    assert_equal two.email, "two@example.com"
  end

  test "unconfirmed email can be empty" do
    one = users(:one)

    assert_nil one.unconfirmed_email
    assert_equal one.valid?, true
  end

  test "unconfirmed email must be a valid Email address" do
    two = users(:two)
    two.unconfirmed_email = "baz.org"
    two.valid?

    assert_includes two.errors.messages[:unconfirmed_email], "is invalid"
  end

  test "unconfirmed email is saved in small case letters" do
    two = users(:two)
    two.unconfirmed_email = "NEW@EXAMPLE.COM"
    two.save

    assert_equal two.unconfirmed_email, "new@example.com"
  end

  test "user can have zero active sessions" do
    two = users(:two)

    assert_empty two.active_sessions
  end

  test "user can have multiple active sessions" do
    one = users(:one)

    assert_equal one.active_sessions.length, 2
  end
end
