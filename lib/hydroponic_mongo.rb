require 'hydroponic_mongo/version'

require 'active_support'
require 'active_support/time'
require 'mongo'

module HydroponicMongo
end

module Mongo
  def self.hydroponic!
    Mongo::Server.prepend(HydroponicMongo::Server)
  end
end

require 'hydroponic_mongo/connection'
require 'hydroponic_mongo/server'