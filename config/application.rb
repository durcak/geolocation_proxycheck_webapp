require_relative 'boot'

require 'rails/all'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Gmaps
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end

# https://github.com/zdennis/activerecord-import/issues/149
require 'activerecord-import/base'

class ActiveRecord::Base
  class << self
    alias :ar_import :import
    remove_method :import
  end
end
