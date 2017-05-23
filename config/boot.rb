# Defines our constants
RACK_ENV = ENV['RACK_ENV'] ||= 'development'  unless defined?(RACK_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
require 'padrino-contrib/exception_notifier'

Bundler.require(:default, RACK_ENV)

# Environment
require 'dotenv'
Dotenv.load "config/.env/.#{Padrino.env}"

##
# Add your before (RE)load hooks here
#
Padrino.before_load do
  Padrino.dependency_paths << Padrino.root('repos/*.rb')
end

##
# Add your after (RE)load hooks here
#
Padrino.after_load do
end

Padrino.load!
