# Load dependencies
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'active_record'
require 'csv'

APP_CONFIG = YAML::load( File.open( "config.yaml" ) )

# Define :db rake tasks
namespace :db do
  desc "Create database using schema defined in ./db/schema.rb" 
  task :create do
    create_db( APP_CONFIG["database_filename"] )
  end
  
  desc "Drop all tables"
  task :drop do
    case APP_CONFIG["database"]["adapter"]
    when "mysql"
      system("mysqladmin -u #{APP_CONFIG["database"]["username"]} -p'#{APP_CONFIG["database"]["password"]}' drop #{APP_CONFIG["database"]["database"]}")
    when "sqlite3"
      File.delete( APP_CONFIG["database_filename"] )
    end    
  end
  
  desc "Seed database with data in ./seeds/"
  task :seed do
    seed_db( APP_CONFIG["database_filename"] )
  end
  
  desc "Export database contents"
  task :export do
    case APP_CONFIG["database"]["adapter"]
    when "mysql"
      system("mysqldump -u #{APP_CONFIG["database"]["username"]} -p'#{APP_CONFIG["database"]["password"]}' #{APP_CONFIG["database"]["database"]} > #{APP_CONFIG["database_export_filename"]}")
    when "sqlite3"
      system("sqlite3 #{APP_CONFIG["database_filename"]} .dump > #{APP_CONFIG["database_export_filename"]}")
    end
  end

end

def seed_db( db_filename ) 
  Dir["./lib/*.rb"].each {|file| require file }
  Dir["./seeds/*.csv"].each do |file|
    table_name = File.basename(file, ".csv")
    
    data = CSV.read( file, { 
      :col_sep => ', ', 
      :quote_char => '"'
      })

    column_names = data[0]
    data.delete_at(0)
    
    case APP_CONFIG["database"]["adapter"]
    when "mysql"
      db = Mysql::real_connect( 
        APP_CONFIG["database"]["host"],
        APP_CONFIG["database"]["username"],
        APP_CONFIG["database"]["password"],
        APP_CONFIG["database"]["database"]    
        )
      query = "INSERT INTO #{table_name} (#{column_names.join(', ')}) VALUES \n"
      inserts = []
      data.each do |row|
        values = row.collect { |t| "'" + t.strip.gsub( "'", "\\'" ) + "'" }
        inserts << "(#{values.join(', ')})"
      end  
      db.query( query << inserts.join(',') << ";" )
      db.close    
    when "sqlite3"
      db = SQLite3::Database.new( db_filename )
      query = ""
      column_names.collect! { |t| "'" + t.strip + "'" }
      data.each do |row| 
        values = row.collect { |t| "'" + t.strip.gsub( "'", "\\'" ) + "'" }
        query << "INSERT INTO #{table_name} (#{column_names.join(', ')}) VALUES (" << values.join(', ') << ");\n"
      end
      db.execute_batch( query )
      db.close
    end
  end
end

def create_db( db_filename )
  case APP_CONFIG["database"]["adapter"]
  when "mysql"
    system("mysqladmin -u #{APP_CONFIG["database"]["username"]} -p'#{APP_CONFIG["database"]["password"]}' create #{APP_CONFIG["database"]["database"]}")
    
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
  
  require "./db/schema"
end