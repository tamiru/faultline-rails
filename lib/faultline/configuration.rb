# frozen_string_literal: true

module Faultline
  class Configuration
    # Dashboard title shown in the header. Set to nil to use "Faultline".
    attr_accessor :application_name

    # Proc called with the controller instance before each request.
    # Return false/nil to deny access; return true to allow.
    # Example:
    #   config.auth_block = ->(controller) { controller.current_user&.admin? }
    attr_accessor :auth_block

    # Proc called with the controller to attach extra data to each exception record.
    # Example:
    #   config.exception_data = ->(controller) { { user_id: controller.current_user&.id } }
    attr_accessor :exception_data

    # Number of exceptions per page (default: 30).
    attr_accessor :per_page

    # Enable/disable the dashboard entirely (default: true).
    attr_accessor :enabled

    def initialize
      @application_name = nil
      @auth_block = nil
      @exception_data = nil
      @per_page = 30
      @enabled = true
    end
  end
end
