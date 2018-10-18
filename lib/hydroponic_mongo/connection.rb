# frozen_string_literal: true

require 'hydroponic_mongo/fake_connection'
require 'hydroponic_mongo/interpreter'

module HydroponicMongo
  class Connection < Mongo::Server::Connection
    include FakeConnection

    def initialize(*args)
      super

      @interpreter = Interpreter.new(@server, self)
      @buffer = []
    end

    def with_connection
      yield self
    end

    def ping
      true
    end

    def reply(*documents)
      reply = Mongo::Protocol::Reply.allocate
      reply.instance_variable_set('@documents', documents.map(&:to_bson))
      reply.instance_variable_set('@flags', [:await_capable])
      reply.instance_variable_set('@number_returned', documents.count)
      reply.instance_variable_set('@starting_from', 0)
      @buffer.push(reply)
    end

    private
    def deliver(messages)
      write(messages)
      messages.last.replyable? ? read(messages.last.request_id) : nil
    end

    def write(messages, buffer = BSON::ByteBuffer.new)
      messages.each do |message|
        @interpreter.handle(message)
      end
    end

    def read(request_id = nil)
      @buffer.shift
    end
  end
end
