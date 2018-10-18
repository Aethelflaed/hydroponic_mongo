# frozen_string_literal: true

require 'hydroponic_mongo/version'

require 'active_support'
require 'active_support/time'
require 'active_support/core_ext'
require 'mongo'

module HydroponicMongo
end

module Mongo
  def self.hydroponic!
    Mongo::Server.prepend(HydroponicMongo::Server)
  end

  def self.debug_requests!
    require 'hydroponic_mongo/mongo_connection_debug'

    Mongo::Server::Connection.prepend(HydroponicMongo::MongoConnectionDebug)
  end
end


require 'hydroponic_mongo/server'
require 'hydroponic_mongo/errors'
