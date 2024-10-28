require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "can create event" do
    visitor = visitors(:one)
    params = { user: { email: "test@test.com", password: "1234" } }
    event = Event.create(method: "POST", path: "/login", params: params, visitor_id: visitor.id)

    assert_not_nil event.id
    assert_equal event.params, params.as_json
  end

  test "page views" do
    views = Event.page_views

    assert_equal views, events.select { |event| event.method == "GET" }.map(&:path).tally
  end

  test "unique page views" do
    views = Event.unique_page_views

    assert_equal views, events.select { |event| event.method == "GET" }.map { |event| [ event.path, event.visitor_id ] }.uniq.map(&:first).tally
  end
end
