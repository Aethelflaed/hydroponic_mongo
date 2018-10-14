# frozen_string_literal: true

require 'hydroponic_mongo/commands'
require 'hydroponic_mongo/reply'

module HydroponicMongo
  class Interpreter
    include Commands

    attr_reader :server, :connection
    attr_reader :database, :collection

    def initialize(server, connection)
      @server = server
      @connection = connection
    end

    def cursor(name, data)
      connection.reply Reply::Cursor.new(name, data)
    end

    def reply_hash(hsh)
      connection.reply Reply::Hash.new(hsh)
    end

    def handle(message)
      binding.pry if HydroponicMongo.debug_request
      payload = message.payload

      if payload['database_name']
        handle_database(payload)
      else
        raise StandardError.new("Check how to handle command: #{payload.inspect}")
      end
    end

    def handle_database(payload)
      @database = server.data[payload['database_name']]

      case payload['command_name'].to_s
      when 'listCollections'
        database_listCollections
      when 'dropDatabase'
        database_drop
      else
        if !handle_collection(payload)
          raise StandardError.new("Check how to handle database command: #{payload.inspect}")
        end
      end
    ensure
      @database = nil
    end

    def handle_collection(payload)
      command = payload['command']
      collection_name = command[payload['command_name'].to_s]
      @collection = database[collection_name]

      case payload['command_name'].to_s
      when 'insert'
        collection_insert(command)
      when 'find'
        collection_find(command)
      else
        return false
      end

      return true
    ensure
      @collection = nil
    end
  end
end
