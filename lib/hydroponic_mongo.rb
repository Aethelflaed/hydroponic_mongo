# frozen_string_literal: true

require 'hydroponic_mongo/version'

require 'active_support'
require 'active_support/time'
require 'active_support/core_ext'
require 'mongo'

module HydroponicMongo
  mattr_accessor(:debug_request) { false }
end

module Mongo
  def self.hydroponic!
    Mongo::Server.prepend(HydroponicMongo::Server)
  end
end

require 'hydroponic_mongo/server'
require 'hydroponic_mongo/errors'
