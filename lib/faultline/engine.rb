module Faultline
  class Engine < ::Rails::Engine
    isolate_namespace Faultline

    engine_name "faultline"

    initializer "faultline.assets", group: :all do |app|
      next unless app.config.respond_to?(:assets) && app.config.assets

      asset_root = root.join("app/assets")

      if defined?(::Propshaft)
        app.config.assets.paths.concat(
          Dir[asset_root.join("*")].select { |path| File.directory?(path) }
        )
      else
        app.config.assets.paths << asset_root
      end
    end
  end
end
