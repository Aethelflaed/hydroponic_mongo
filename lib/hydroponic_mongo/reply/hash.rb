module HydroponicMongo
  class Reply::Hash < Reply
    def initialize(hsh)
      @hsh = hsh
    end

    def to_bson
      new_document do |doc|
        @hsh.each do |k, v|
          doc.store k, v
        end
        doc.store 'ok', 1.0
      end
    end
  end
end
