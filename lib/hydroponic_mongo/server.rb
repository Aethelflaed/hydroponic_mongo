# frozen_string_literal: true

require 'hydroponic_mongo/connection'
require 'hydroponic_mongo/monitor'
require 'hydroponic_mongo/database'

module HydroponicMongo
  module Server
    attr_reader :databases

    def initialize(address, cluster, monitoring, event_listeners, options = {})
      @address = address
      @cluster = cluster
      @monitoring = monitoring
      @options = options.freeze
      publish_sdam_event(
        Mongo::Monitoring::SERVER_OPENING,
        Mongo::Monitoring::Event::ServerOpening.new(address, cluster.topology)
      )
      @monitor = HydroponicMongo::Monitor.new(address, event_listeners, options.merge(app_metadata: cluster.app_metadata))
      monitor.scan!
      monitor.run!
      ObjectSpace.define_finalizer(self, self.class.finalize(monitor))

      @databases = Hash.new{|h, k| h[k] = Database.new(self, k)}
    end

    def pool
      @connection ||= HydroponicMongo::Connection.new(self, self.options)
    end

    def dropDatabase(name)
      @databases.delete(name)
    end
  end
end
