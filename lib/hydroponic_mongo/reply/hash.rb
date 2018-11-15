module HydroponicMongo
  class Reply::Hash < Reply
    attr_reader :data

    def initialize(data)
      @data = data.deep_dup
    end

    def to_bson
      new_document do |doc|
        @data.each do |k, v|
          doc.store k, v
        end
        doc.store 'ok', 1.0
      end
    end
  end
end
