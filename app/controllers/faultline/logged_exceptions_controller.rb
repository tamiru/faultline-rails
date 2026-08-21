module Faultline
  class LoggedExceptionsController < ApplicationController
    cattr_accessor :application_name

    helper_method :params_filters

    def index
      @exception_names = LoggedException.class_names
      @controller_actions = LoggedException.controller_actions
      @exceptions = filtered_exceptions
    end

    def query
      @exceptions = filtered_exceptions

      respond_to do |format|
        format.turbo_stream
        format.html { render :query }
      end
    end

    def feed
      @exceptions = LoggedException.all

      respond_to do |format|
        format.rss { render layout: false }
      end
    end

    def show
      @exception = LoggedException.find(params[:id])

      respond_to do |format|
        format.turbo_stream
        format.html
      end
    end

    def destroy
      @exception = LoggedException.find(params[:id])
      @exception.destroy!

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to logged_exceptions_path, status: :see_other }
      end
    end

    def destroy_all
      exceptions = if params[:ids].present?
        LoggedException.where(id: params[:ids].to_s.split(","))
      else
        filtered_scope
      end
      exceptions.delete_all
      @exceptions = filtered_exceptions

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to logged_exceptions_path(params_filters) }
      end
    end

    def clear
      LoggedException.delete_all
      @exceptions = filtered_exceptions

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path }
      end
    end

    private

    def params_filters
      {
        query: params[:query],
        date_ranges_filter: params[:date_ranges_filter],
        exception_names_filter: params[:exception_names_filter],
        controller_actions_filter: params[:controller_actions_filter]
      }.compact
    end

    def filtered_exceptions
      filtered_scope.paginate(page: params[:page], per_page: 30)
    end

    def filtered_scope
      exceptions = LoggedException.sorted
      exceptions = exceptions.where(id: params[:id]) if params[:id].present?
      exceptions = exceptions.message_like(params[:query]) if params[:query].present?
      exceptions = exceptions.days_old(params[:date_ranges_filter]) if params[:date_ranges_filter].present?
      exceptions = exceptions.by_exception_class(params[:exception_names_filter]) if params[:exception_names_filter].present?

      if params[:controller_actions_filter].present?
        controller_name, action_name = params[:controller_actions_filter].split("/", 2)
        exceptions = exceptions.by_controller(controller_name.underscore)
        exceptions = exceptions.by_action(action_name.downcase) if action_name.present?
      end

      exceptions
    end
  end
end
