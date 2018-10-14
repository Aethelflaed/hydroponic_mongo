module HydroponicMongo
  class Reply::Count < Reply
    def initialize(n)
      @n = n
    end

    def to_bson
      new_document do |doc|
        doc.store 'n', @n
        doc.store 'ok', 1.0
      end
    end
  end
end
