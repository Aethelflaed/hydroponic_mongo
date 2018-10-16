require 'bundler/setup'
require 'simplecov'
SimpleCov.configure do
  add_filter '/test/'
end
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "hydroponic_mongo"

require "minitest/autorun"
