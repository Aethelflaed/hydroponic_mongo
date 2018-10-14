module HydroponicMongo
  class Interpreter
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def handle(message)
      payload = message.payload

      if payload['database_name']
        connection.data[payload['database_name']].command(connection, payload['command'])
      else
        raise StandardError.new("Check how to handle: #{payload.inspect}")
      end
    end
  end
end
