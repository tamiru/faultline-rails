class CreateFaultlineLoggedExceptions < ActiveRecord::Migration[8.0]
  def change
    create_table :faultline_logged_exceptions do |t|
      t.string :exception_class
      t.string :controller_name
      t.string :action_name
      t.text :message
      t.text :backtrace
      t.text :environment
      t.text :request
      t.string :user_info
      t.string :user_agent
      t.string :remote_ip

      t.timestamps
    end
  end
end
