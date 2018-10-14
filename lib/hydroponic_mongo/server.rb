require 'hydroponic_mongo/connection'
require 'hydroponic_mongo/monitor'
require 'hydroponic_mongo/data'

module HydroponicMongo
  module Server
    attr_reader :data

    def initialize(address, cluster, monitoring, event_listeners, options = {})
      @address = address
      @data = Data.new(address)
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
    end

    def pool
      @connection ||= HydroponicMongo::Connection.new(self, self.options)
    end
  end
end
