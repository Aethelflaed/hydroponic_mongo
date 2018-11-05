# frozen_string_literal: true

require 'hydroponic_mongo/commands'
require 'hydroponic_mongo/reply'

module HydroponicMongo
  class Interpreter
    include Commands

    attr_reader :server, :connection

    def initialize(server, connection)
      @server = server
      @connection = connection
    end

    def reply_cursor(name, data)
      connection.reply Reply::Cursor.new(name, data)
    end

    def reply_hash(hsh)
      connection.reply Reply::Hash.new(hsh)
    end

    def handle(message)
      @payload = message.payload
      @cmd = payload['command']

      method = "$cmd.#{payload['command_name']}"
      if respond_to?(method)
        public_send(method)
      else
        raise CommandNotImplementedError.new(payload)
      end

    ensure
      @payload, @cmd = nil, nil
      @database, @collection = nil, nil
    end

    attr_reader :payload, :cmd

    def database
      if payload
        @database ||= Database.new(payload['database_name'])
      end
    end

    def collection
      if database
        @collection ||=
          begin
            collection_name = payload['command'][payload['command_name'].to_s]
            database[collection_name]
          end
      end
    end
  end
end
