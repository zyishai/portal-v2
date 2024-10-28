require "test_helper"

class VisitorTest < ActiveSupport::TestCase
  test "time on site" do
    time = Visitor.time_on_site

    assert_equal time.sort, visitors.map { |visitor| [ visitor.id, visitor.events.map(&:created_at).max-visitor.events.map(&:created_at).min ] }.sort
  end

  test "total time for visitor" do
    visitor = visitors(:one)

    total_time = Visitor.total_time_on_site_for_visitor(visitor)
    created_times = visitor.events.map(&:created_at)

    assert_equal total_time, created_times.max - created_times.min
  end

  test "average time for visitor" do
    skip "Didn't understand the code..."
  end
end
