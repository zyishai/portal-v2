require "test_helper"

class TrackEventFlowTest < ActionDispatch::IntegrationTest
  test "does not track by default" do
    assert_no_enqueued_jobs do
      get root_path
    end
  end

  test "tracking access after enabling analytics" do
    post enable_analytics_path

    args_matcher = ->(args) { args[0][:method] == "GET" and args[0][:path] == "/" }
    assert_enqueued_with(job: CreateEventJob, args: args_matcher) do
      get root_path
    end
  end

  test "tracking access for logged in users" do
    user = users(:three)

    post login_path, params: { user: { email: user.email, password: "PasswordThree" } }
    post enable_analytics_path

    args_matcher = ->(args) { args[0][:method] === "GET" and args[0][:path] === account_path }
    assert_enqueued_with(job: CreateEventJob, args: args_matcher) do
      get account_path
    end
  end
end
