# Load dependencies
require "csv"
require "rubygems"
require "bundler/setup"
Bundler.require(:default)
require 'active_record'
require 'pathname'
require './config'


# Define :db rake tasks
namespace :db do
  desc "Create database using schema defined in ./db/schema.rb" 
  task :create do
    create_db( $database_filename )
  end
  desc "Drop all tables"
  task :drop do
    File.delete( $database_filename )
  end
  desc "Seed database with data in ./seeds/"
  task :seed do
    seed_db( $database_filename )
  end
  desc "Export database contents"
  task :export do
    export_db( $database_filename )
  end

end

def export_db( db_filename )
  
end

def seed_db( db_filename )
  db = SQLite3::Database.new( db_filename )
   
  Dir["./lib/*.rb"].each {|file| require file }
  Dir["./seeds/*.csv"].each do |file|
    table_name = File.basename(file, ".csv")
    data = CSV.read(file) # loads csv data into [line][data]

    column_names = data[0].collect { |t| "'" + t.strip + "'" }
    data.delete_at(0)
    
    query = ""
    
    data.each do |row| 
      values = row.collect { |t| "'" + t.strip.gsub( "'", "\\'" ) + "'" }
      query << "INSERT INTO #{table_name} (#{column_names.join(', ')}) VALUES (" << values.join(', ') << ");\n"
    end

    db.execute_batch( query )
  end
  
  db.close
end

def create_db( db_filename )
  ActiveRecord::Base.establish_connection(
    :adapter  => "sqlite3",
    :database => db_filename
  )
  
  require "./db/schema"
end