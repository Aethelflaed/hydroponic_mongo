require 'hydroponic_mongo/fake_connection'

module HydroponicMongo
  class Monitor < Mongo::Server::Monitor
    def initialize(address, listeners, options = {})
      super

      @connection = MonitorConnection.new(address, options)
    end
  end

  class MonitorConnection < Mongo::Server::Monitor::Connection
    include FakeConnection

    def ismaster
      @ismaster ||= BSON::Document.new.tap do |doc|
        doc.store 'ismaster', true
        doc.store 'maxBsonObjectSize', 16777216
        doc.store 'maxMessageSizeBytes', 48000000
        doc.store 'maxWriteBatchSize', 1000
        doc.store 'maxWireVersion', 5
        doc.store 'minWireVersion', 0
        doc.store 'readOnly', false
        doc.store 'ok', 1.0
      end

      @ismaster.store 'localTime', Time.now.strftime('%Y-%m-%d %H:%M:%S %Z')

      return @ismaster
    end
  end
end
