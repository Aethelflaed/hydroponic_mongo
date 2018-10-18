# frozen_string_literal: true

module HydroponicMongo
  module MongoConnectionDebug
    def write(messages, buffer = BSON::ByteBuffer.new)
      payload = messages[0].payload
      binding.pry

      super
    end

    def read(request_id = nil)
      super.tap do |result|
        binding.pry
      end
    end
  end
end
