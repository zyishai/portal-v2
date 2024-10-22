ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def login(creds)
      post login_path, params: { user: { email: creds[:email], password: creds[:password] } }
    end

    def email_link(email, string)
      body = email.html_part&.body || email.body
      document = Capybara.string(body.to_s)
      link = document.find(:link, string)[:href]

      localize_link(link)
    end

    private

    def localize_link(link)
      uri = URI.parse(link)

      if uri.query
        "#{uri.path}?#{uri.query}"
      else
        uri.path
      end
    end
  end
end
