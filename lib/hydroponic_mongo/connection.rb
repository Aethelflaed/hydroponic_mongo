# frozen_string_literal: true

require 'hydroponic_mongo/fake_connection'
require 'hydroponic_mongo/interpreter'

module HydroponicMongo
  class Connection < Mongo::Server::Connection
    include HydroponicMongo::FakeConnection

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

      # start_size = 0
      # messages.each do |message|
      #   message.serialize(buffer, max_bson_object_size)
      #   if max_message_size &&
      #       (buffer.length - start_size) > max_message_size
      #     raise Error::MaxMessageSize.new(max_message_size)
      #     start_size = buffer.length
      #   end
      # end
      # ensure_connected{ |socket| socket.write(buffer.to_s) }
    end

    def read(request_id = nil)
      binding.pry if HydroponicMongo.debug_request
      @buffer.shift
      # ensure_connected do |socket|
      #   Protocol::Message.deserialize(socket, max_message_size, request_id)
      # end
    end
  end
end
