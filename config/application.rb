require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NextTrain
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = 'Eastern Time (US & Canada)'

    #config.autoload_paths += Dir[ Rails.root.join('app', 'jobs', 'gtfs_import', '**/') ]
    #config.autoload_paths += Dir[ Rails.root.join('app', 'models', 'api', 'v1', '**/') ]
    config.autoload_paths += Dir[ Rails.root.join('app', 'models', 'api', 'v1', 'responses') ]
  end
end
