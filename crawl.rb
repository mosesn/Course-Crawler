# Load dependencies
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'active_record'

APP_CONFIG = YAML::load( File.open( "config.yaml" ) )

# Configure ActiveRecord
case APP_CONFIG["database"]["adapter"]
when "mysql"
  ActiveRecord::Base.establish_connection(
    :adapter  => "mysql",
    :host     => APP_CONFIG["database"]["host"],
    :username => APP_CONFIG["database"]["username"],
    :password => APP_CONFIG["database"]["password"],
    :database => APP_CONFIG["database"]["database"]
  )
when "sqlite3"
  ActiveRecord::Base.establish_connection(
    :adapter  => "sqlite3",
    :database => $database_filename # set in config.db
  )
  # Disable sycnchronous writes for performance gain
  # NOTE: Database may be corrupted if computer power is lost mid-crawl
  c = ::ActiveRecord::Base.connection
  c.execute("PRAGMA default_synchronous=OFF")
  c.execute("PRAGMA synchronous=OFF")
end

# Load models
Dir["./lib/*.rb"].each {|file| require file }

# Crawl course directory
Directory.crawl