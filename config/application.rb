require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TaskRoom
  class Application < Rails::Application
    
    # time zone
    config.time_zone = 'Tokyo'
    
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # i18n
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]

    # not generate the files below when rails g
    config.generators do |g|
      g.stylesheets false   #styleシート
      g.javascripts false   #javascript
      g.helper false        #ヘルパー
      g.test_framework false #テストファイル
    end
  end
end
