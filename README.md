# Faultline Rails

Faultline is a production-friendly exception dashboard for Rails 8. It records unhandled application exceptions and gives your team a fast, searchable view of messages, requests, environments, and backtraces.

The dashboard is server-rendered and progressively enhanced with:

- Turbo Frames for filtering and opening exception details without full-page navigation.
- Turbo Streams for deleting one, many, or all exceptions.
- Stimulus for loading state and small interaction behavior.
- Tailwind-compatible utility classes for a responsive dashboard UI.

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

Install the dependencies and copy the engine migration:

```bash
bundle install
bin/rails app:faultline:install:migrations
bin/rails db:migrate
```

Mount the dashboard in your application:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount Faultline::Engine => "/faultline"
end
```

The dashboard is now available at `/faultline`.

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

The dashboard contains sensitive information, including request parameters, environment variables, and source paths. Do not expose it to unauthenticated public users.

Attach your application's authorization callback:

```ruby
# config/initializers/faultline.rb
Rails.application.config.to_prepare do
  Faultline::LoggedExceptionsController.before_action :require_admin!
end
```

Replace `require_admin!` with the authentication method provided by your application. You can also configure a policy, basic authentication, or an internal-only route at the host application level.

## Rails 8 frontend setup

Faultline includes `turbo-rails` and `stimulus-rails` as dependencies. Install the host application's Hotwire entry points when needed:

```bash
bin/rails turbo:install
bin/rails stimulus:install
```

The default Rails 8 import-map setup will load Faultline's Stimulus controller through the engine asset pipeline. If your application uses a JavaScript bundler, register the controller from `app/javascript/controllers/faultline_controller.js` in your Stimulus application:

```javascript
import FaultlineController from "./faultline_controller"

application.register("faultline", FaultlineController)
```

## Tailwind setup

Faultline's dashboard uses Tailwind utility classes. Add the gem's view directory to the sources scanned by your Tailwind build; otherwise the host application will purge the dashboard classes.

For Tailwind CSS v4, add a source entry to the application's Tailwind stylesheet. Use the absolute path returned by Bundler for the installed gem:

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

You can find the installed path with:

```bash
bundle show faultline-rails
```

## Configuration

Set a title for the dashboard and attach additional application data to each record:

```ruby
# config/initializers/faultline.rb
Rails.application.config.to_prepare do
  Faultline::LoggedExceptionsController.application_name = "Acme"

  ApplicationController.exception_data = lambda do |controller|
    {
      request_id: controller.request.request_id,
      user_id: controller.current_user&.id
    }
  end
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
