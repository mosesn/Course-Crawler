# Load dependencies
require "rubygems"
require "bundler/setup"
Bundler.require(:default)
require 'active_record'
require "./config"

# Configure ActiveRecord
ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => $database_filename # set in config.db
)

# Load models
Dir["./lib/*.rb"].each {|file| require file }


# Crawl course directory
Directory.crawl