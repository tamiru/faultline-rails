# Changelog

All notable changes to Faultline Rails will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-08-21

### Added
- **Install generator** — `bin/rails generate faultline:install` sets up routes, migration, and initializer in one command.
- **Configuration DSL** — `Faultline.configure` block for auth, app name, per-page, and exception data.
- **Auth by default** — `auth_block` configuration prevents unauthenticated access. Dashboard returns 403 when no auth is configured.
- **Self-contained CSS** — Dashboard works without Tailwind CSS. Custom stylesheets are engine-provided.
- **Database indexes** — Added indexes on `created_at`, `exception_class`, and `[controller_name, action_name]` for faster queries.
- **Backward compatibility** — Legacy `ExceptionLoggable` class attributes still work alongside the new configuration DSL.

### Fixed
- **Message formatting** — Exception messages are no longer nil when no extra data is attached.
- **Removed stray `.gem` files** from the repository.

### Changed
- Views use engine-scoped CSS classes instead of Tailwind utility classes.
- Layout no longer depends on host application assets.

## [0.1.1] - 2026-08-20

### Added
- `faultline:tailwind:sources` rake task for Tailwind v4 source discovery.

## [0.1.0] - 2024-03-30

### Added
- Initial release.
- Exception logging via `Faultline::ExceptionLoggable`.
- Dashboard with filtering, search, pagination.
- Turbo Frames and Streams for SPA-like UX.
- RSS feed.
- Turbo Stream-based delete operations.
