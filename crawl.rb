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
  # Disable sycnchronous writes for performance gain
  # NOTE: Database may be corrupted if computer power is lost mid-crawl
  c = ::ActiveRecord::Base.connection
  c.execute("PRAGMA default_synchronous=OFF")
  c.execute("PRAGMA synchronous=OFF")


# Load models
Dir["./lib/*.rb"].each {|file| require file }


# Crawl course directory
Directory.crawl