#!/usr/bin/env ruby

# include gems
require 'mysql2'
require 'plist'

# include path
$:.unshift File.dirname(__FILE__) + '/lib'

# require lib
require 'itunes_import_database'
require 'itunes_import'

# define database params
db_params = {
  host: 'localhost',
  username: 'itunes_import',
  password: 'itunes_import',
  database: 'itunes_import',
  table: 'tracks',
}

# initialize db
ItunesImport.init db_params

options = {
  truncate: true
}

# import XML library to MySQL
ItunesImport.import 'Library.xml', options

# query
#ItunesImport.albums_by_highest_average_rating

# query
#ItunesImport.indie_albums_by_highest_average_rating
