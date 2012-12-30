require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)

$: << "#{Dir.pwd}/lib"
require 'sequel-cacheable'

DB = Sequel.sqlite
DB.create_table(:mock) do
  primary_key :id, :auto_increment => true
  String :name
end

require 'memcache/null_server'
class Mock < Sequel::Model(:mock)
  plugin :cacheable, Redis.new(server: 'localhost:6379'), :query_cache => true
end
