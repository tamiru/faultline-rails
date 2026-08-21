# Faultline Rails

Faultline is a production-friendly exception dashboard for Rails 8. It records unhandled application exceptions and gives your team a fast, searchable view of messages, requests, environments, and backtraces.

The dashboard is server-rendered and progressively enhanced with:

- Turbo Frames for filtering and opening exception details without full-page navigation.
- Turbo Streams for deleting one, many, or all exceptions.
- Stimulus for loading state and small interaction behavior.
- Built-in CSS for a responsive dashboard UI that works out of the box.

## Requirements

- Ruby 3.2 or newer
- Rails 8.0 or newer
- A database supported by Active Record

## Installation

Add Faultline to your application:

```ruby
# Gemfile
gem "faultline-rails"
```

Run the install generator to set up everything in one step:

```bash
bundle install
bin/rails generate faultline:install
bin/rails db:migrate
```

This will:
1. Copy the database migration with proper indexes.
2. Create a configuration initializer at `config/initializers/faultline.rb`.
3. Mount the engine in your routes.

The dashboard is now available at `/faultline`.

> **Note:** The generator mounts the engine at `/faultline` by default. You can change the mount path by editing `config/routes.rb`.

## Start logging exceptions

Include `Faultline::ExceptionLoggable` in your application controller:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Faultline::ExceptionLoggable
end
```

Faultline logs the exception and then re-raises it so Rails keeps its normal error handling, status codes, and error pages.

## Protect the dashboard

The dashboard contains sensitive information, including request parameters, environment variables, and source paths. **Do not expose it to unauthenticated public users.**

By default, the dashboard returns `403 Forbidden` for all requests. Configure authentication in your initializer:

```ruby
# config/initializers/faultline.rb
Rails.application.config.to_prepare do
  Faultline.configure do |config|
    config.auth_block = lambda do |controller|
      # Return true if the user is authorized to view the dashboard.
      # Examples:
      controller.authenticate_user!  # Devise
      # controller.current_user&.admin?  # Custom auth
      # false  # Block everyone (default)
    end
  end
end
```

## Configuration

Configure Faultline through the block-style DSL in your initializer:

```ruby
# config/initializers/faultline.rb
Rails.application.config.to_prepare do
  Faultline.configure do |config|
    # Dashboard title
    config.application_name = "Acme"

    # Items per page (default: 30)
    config.per_page = 50

    # Authentication block (see "Protect the dashboard" above)
    config.auth_block = lambda do |controller|
      controller.current_user&.admin?
    end
  end
end
```

You can also attach additional application data to each recorded exception:

```ruby
ApplicationController.exception_data = lambda do |controller|
  {
    request_id: controller.request.request_id,
    user_id: controller.current_user&.id
  }
end
```

Exclude trusted private networks from the dashboard's local-request handling:

```ruby
class ApplicationController < ActionController::Base
  include Faultline::ExceptionLoggable

  consider_local "10.0.0.0/8", "192.168.0.0/16"
end
```

Rails' `filter_parameters` configuration is respected before request parameters are stored.

## Frontend setup

### Hotwire (default)

Faultline includes `turbo-rails` and `stimulus-rails` as dependencies. If your Rails app already has Hotwire installed (the default for Rails 8), no extra setup is needed.

If you need to install Hotwire:

```bash
bin/rails turbo:install
bin/rails stimulus:install
```

### Styling

Faultline ships with its own built-in CSS stylesheet that works out of the box. No Tailwind configuration is required.

If your application uses Tailwind CSS and you want Faultline to use your Tailwind theme instead, you can configure the gem's view directory as a Tailwind source. Use the absolute path returned by Bundler:

```bash
bundle show faultline-rails
```

For Tailwind CSS v4, add a source entry:

```css
@import "tailwindcss";
@source "/absolute/path/to/faultline-rails/app/views";
```

For Tailwind CSS v3, add the gem path to `content` in `tailwind.config.js`:

```javascript
const faultlinePath = "/absolute/path/to/faultline-rails"

module.exports = {
  content: [
    "./app/views/**/*.{erb,html}",
    `${faultlinePath}/app/views/**/*.html.erb`
  ]
}
```

## Dashboard features

- Search exception messages.
- Filter by exception class, controller/action, or age.
- Open full exception details in a Turbo Frame.
- Delete individual exceptions without leaving the page.
- Delete the currently visible result set.
- Clear the complete history.
- Subscribe to the RSS feed at `/faultline/logged_exceptions/feed.rss`.

## Data storage

The engine creates a `faultline_logged_exceptions` table containing the exception class, controller/action, message, backtrace, request, environment, user information, user agent, remote IP, and timestamps.

Exception records can contain secrets. Apply your normal database encryption, retention, backup, and access-control policies.

## Development

Run the test suite with:

```bash
bin/rails test
```

The repository includes a Rails dummy application under `test/dummy` for engine integration testing.

## License

Faultline Rails is released under the [MIT License](MIT-LICENSE).
