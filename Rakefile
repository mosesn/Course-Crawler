# Load dependencies
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require 'csv'
require 'mysql2'

APP_CONFIG = YAML::load( File.open( "config.yaml" ) )

# Define :db rake tasks
namespace :db do
  desc "Create database using schema defined in ./db/schema.rb" 
  task :create do
    system("mysqladmin -u #{APP_CONFIG["database"]["username"]} -p'#{APP_CONFIG["database"]["password"]}' create #{APP_CONFIG["database"]["database"]}")
  end
  
  desc "Drop all tables"
  task :drop do
    system("mysqladmin -u #{APP_CONFIG["database"]["username"]} -p'#{APP_CONFIG["database"]["password"]}' drop #{APP_CONFIG["database"]["database"]}")
  end
  
  desc "Seed database with data in ./seeds/"
  task :seed do
    seed_db
  end

  desc "Export database contents"
  task :export do
    system("mysqldump -u #{APP_CONFIG["database"]["username"]} -p'#{APP_CONFIG["database"]["password"]}' #{APP_CONFIG["database"]["database"]} > #{APP_CONFIG["database_export_filename"]}")
  end
end

def seed_db
  db = Mysql2::Client.new(
    :host => APP_CONFIG["database"]["host"],
    :username => APP_CONFIG["database"]["username"],
    :password => APP_CONFIG["database"]["password"],
    :database => APP_CONFIG["database"]["database"],
    )
    
  Dir["./seeds/*.csv"].each do |file|
    table_name = File.basename(file, ".csv")

    # clear rows in table
    db.query( "DELETE FROM #{table_name}" )

    # read data from csv file
    data = CSV.read( file, { 
      :col_sep => ', ', 
      :quote_char => '"'
      })

    column_names = data[0]
    data.delete_at(0)
    
    # generate insert query
    query = "INSERT INTO #{table_name} (#{column_names.join(', ')}) VALUES \n"
    inserts = []
    data.each do |row|
      values = row.collect { |t| "'" + t.strip.gsub( "'", "\\'" ) + "'" }
      inserts << "(#{values.join(', ')})"
    end  
    
    # run query on db connection
    db.query( query << inserts.join(',') << ";" )
  end
  db.close
end