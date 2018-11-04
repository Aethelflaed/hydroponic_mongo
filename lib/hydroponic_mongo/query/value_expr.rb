# frozen_string_literal: true

module HydroponicMongo
  class Query
    module ValueExpr
      extend self

      def resolve(query, doc, expr)
        if expr.is_a?(Hash) && expr.keys.first[0] == '$'
          expr.all? do |op, arg|
            if respond_to?(op)
              public_send(op, doc, arg)
            else
              QueryOperatorNotImplementedError.new(query, op, arg, doc)
            end
          end
        else
          public_send('$eq', doc, expr)
        end
      end

      define_method('$eq') do |doc, arg|
        doc == arg
      end

      define_method('$ne') do |doc, arg|
        doc != arg
      end

      define_method('$gt') do |doc, arg|
        doc > arg
      end

      define_method('$gte') do |doc, arg|
        doc >= arg
      end

      define_method('$lt') do |doc, arg|
        doc < arg
      end

      define_method('$lte') do |doc, arg|
        doc <= arg
      end

      define_method('$in') do |doc, arg|
        arg.include?(doc)
      end

      define_method('$nin') do |doc, arg|
        !arg.include?(doc)
      end

      define_method('$exists') do |doc, arg|
        true
      end
    end
  end
end
