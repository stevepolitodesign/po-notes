ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock"
require "vcr"
require "sidekiq/testing"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # https://github.com/paper-trail-gem/paper_trail#7a-minitest
  def with_versioning
    was_enabled = PaperTrail.enabled?
    was_enabled_for_request = PaperTrail.request.enabled?
    PaperTrail.enabled = true
    PaperTrail.request.enabled = true
    begin
      yield
    ensure
      PaperTrail.enabled = was_enabled
      PaperTrail.request.enabled = was_enabled_for_request
    end
  end

  def user_not_authorized
    follow_redirect!
    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  # https://github.com/vcr/vcr#usage
  VCR.configure do |config|
    config.cassette_library_dir = "test/vcr_cassettes"
    config.hook_into :webmock
    config.ignore_hosts(
      "chromedriver.storage.googleapis.com",
      "github.com/mozilla/geckodriver/releases",
      "selenium-release.storage.googleapis.com",
      "developer.microsoft.com/en-us/microsoft-edge/tools/webdriver",
      "127.0.0.1"
    )
  end
end
