require "test_helper"

module Faultline
  class LoggedExceptionControllerTest < ActionDispatch::IntegrationTest
    include Faultline::Engine.routes.url_helpers

    setup do
      @exception = Faultline::LoggedException.create!(
        exception_class: "RuntimeError",
        controller_name: "faultline/test",
        action_name: "show",
        message: "Something went wrong",
        backtrace: "app/models/example.rb:1",
        environment: "RACK_ENV: test",
        request: "GET /faultline",
        remote_ip: "127.0.0.1"
      )
    end

    test "should get index" do
      get root_url
      assert_response :success
      assert_select "[data-controller='faultline']"
      assert_select "turbo-frame#exceptions"
      assert_select "turbo-frame#exception-details"
      assert_includes response.body, "Something went wrong"
    end

    test "should get show" do
      get logged_exception_url(@exception)
      assert_response :success
      assert_select "turbo-frame#exception-details"
      assert_includes response.body, "RACK_ENV: test"
    end

    test "filters with a turbo stream response" do
      get query_logged_exceptions_url(query: "Something"),
        headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }

      assert_response :success
      assert_includes response.media_type, "turbo-stream"
      assert_includes response.body, "Something went wrong"
    end
  end
end
