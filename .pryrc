require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)

$: << "#{Dir.pwd}/lib"
require 'sequel-cacheable'

DB = Sequel.sqlite
