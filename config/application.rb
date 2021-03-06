require File.expand_path('../boot', __FILE__)

# require 'rails/all'
require "action_controller/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
# Bundler.require(*Rails.groups)
if defined?(Bundler)
  Bundler.require *Rails.groups(:assets => %w(production development test))
end

# Dir.foreach(File.expand_path('../../app/utils',__FILE__)) do |file|
#   require file;puts "require #{file}" if file =~ /\.rb$/
# end

module Jiyu
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    js_path = Rails.root.join('app', 'assets', 'javascripts')
    js = js_path.each_child.collect{|pn|pn.basename.to_s if pn.basename.to_s =~ /\.js$/}.compact
    css_path = js_path = Rails.root.join('app', 'assets', 'stylesheets')
    css = css_path.each_child.collect{|pn|pn.basename.to_s if pn.basename.to_s =~ /\.css$/}.compact
    js += css
    config.encoding = "utf-8"
    Mongoid.raise_not_found_error = false
    config.assets.precompile += js
    config.assets.precompile += %w[*.png *.jpg *.jpeg *.gif]
    config.autoload_paths += %W(#{config.root}/app/utils/ #{config.root}/app/models/u9/)
    require 'net/ssh'
    require 'net/scp'
  end
end
