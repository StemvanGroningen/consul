module Consul
  class Application < Rails::Application
    initializer :exclude_custom_locales_automatic_loading, before: :add_locales do
      paths.add "config/locales", glob: "**[^custom]*/*.{rb,yml}"
    end
  end
end
