require 'bundler/setup'

require 'pry'
require 'simplecov'
SimpleCov.configure do
  add_filter '/test/'
end
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "hydroponic_mongo"

Mongo::Logger.logger = Logger.new(File.open(File.expand_path('../../log/test.log', __FILE__), 'a+'))

Mongo.hydroponic!

require "minitest/autorun"
