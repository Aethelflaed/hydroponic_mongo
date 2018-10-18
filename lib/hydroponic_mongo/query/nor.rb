module HydroponicMongo
  class Query
    module Nor
      def self.to_proc(query, expressions)
        -> ((id, doc)) {
          expressions.none? do |expression|
            expression.all? do |key, value|
              query.expression(key, value).call([id, doc])
            end
          end
        }
      end
    end
  end
end
