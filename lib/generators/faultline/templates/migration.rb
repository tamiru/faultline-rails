# frozen_string_literal: true

class CreateFaultlineLoggedExceptions < ActiveRecord::Migration<%= "[#{ActiveRecord::Migration.current_version}]" %>
  def change
    create_table :faultline_logged_exceptions do |t|
      t.string :exception_class
      t.string :controller_name
      t.string :action_name
      t.text   :message
      t.text   :backtrace
      t.text   :environment
      t.text   :request
      t.string :user_info
      t.string :user_agent
      t.string :remote_ip

      t.timestamps
    end

    add_index :faultline_logged_exceptions, :created_at
    add_index :faultline_logged_exceptions, :exception_class
    add_index :faultline_logged_exceptions, [:controller_name, :action_name]
  end
end
