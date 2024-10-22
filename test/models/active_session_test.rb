require "test_helper"

class ActiveSessionTest < ActiveSupport::TestCase
  test "active session must belong to a user" do
    session = ActiveSession.new
    session.valid?

    assert_includes session.errors.messages[:user], "must exist"
  end

  test "active session have a remember token" do
    session = ActiveSession.new(user: users(:one))

    assert_not_nil session.remember_token
    assert_not_empty session.remember_token
  end
end
