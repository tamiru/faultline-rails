# frozen_string_literal: true

require "test_helper"

class Faultline::ConfigurationTest < ActiveSupport::TestCase
  setup do
    @original_config = Faultline.configuration.dup
  end

  teardown do
    Faultline.instance_variable_set(:@configuration, @original_config)
  end

  test "default configuration values" do
    config = Faultline::Configuration.new
    assert_nil config.application_name
    assert_nil config.auth_block
    assert_nil config.exception_data
    assert_equal 30, config.per_page
    assert config.enabled
  end

  test "configure block sets values" do
    Faultline.configure do |config|
      config.application_name = "MyApp"
      config.per_page = 50
      config.enabled = false
    end

    assert_equal "MyApp", Faultline.configuration.application_name
    assert_equal 50, Faultline.configuration.per_page
    assert_not Faultline.configuration.enabled
  end

  test "configure block sets auth_block" do
    auth = ->(controller) { controller.current_user.present? }
    Faultline.configure { |c| c.auth_block = auth }

    assert_equal auth, Faultline.configuration.auth_block
  end

  test "configure block sets exception_data" do
    data = ->(controller) { { user_id: 1 } }
    Faultline.configure { |c| c.exception_data = data }

    assert_equal data, Faultline.configuration.exception_data
  end

  test "application_name accessor on Faultline module" do
    Faultline.application_name = "TestApp"
    assert_equal "TestApp", Faultline.application_name
    assert_equal "TestApp", Faultline.configuration.application_name
  end

  test "configuration is a singleton" do
    config1 = Faultline.configuration
    config2 = Faultline.configuration
    assert_same config1, config2
  end
end
