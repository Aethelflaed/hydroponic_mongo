require 'hydroponic_mongo/fake_connection'

module HydroponicMongo
  class Connection < Mongo::Server::Connection
    include HydroponicMongo::FakeConnection

    def with_connection
      yield self
    end

    def ping
      true
    end

    private
    def deliver(messages)
      write(messages)
      messages.last.replyable? ? read(messages.last.request_id) : nil
    end

    def write(messages, buffer = BSON::ByteBuffer.new)
      binding.pry
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
      binding.pry
      # ensure_connected do |socket|
      #   Protocol::Message.deserialize(socket, max_message_size, request_id)
      # end
    end
  end
end
