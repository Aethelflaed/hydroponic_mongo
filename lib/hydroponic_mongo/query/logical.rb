module HydroponicMongo
  class Query
    module Logical
      def and_expressions(expressions)
        -> (object) {
          expressions.all? do |expression|
            expression.all? do |key, value|
              expression(key, value).call(object)
            end
          end
        }
      end

      def nor_expressions(expressions)
        -> (object) {
          expressions.none? do |expression|
            expression.all? do |key, value|
              expression(key, value).call(object)
            end
          end
        }
      end

      def or_expressions(expressions)
        -> (object) {
          expressions.any? do |expression|
            expression.all? do |key, value|
              expression(key, value).call(object)
            end
          end
        }
      end
    end
  end
end
