# frozen_string_literal: true

module HydroponicMongo
  class Query
    module ArrayExpr
      def self.resolve(query, id, doc, expr)
        if expr.is_a?(Hash) && expr.keys.first[0] == '$'
          expr.all? do |op, arg|
            resolve_op(query, id, doc, op, arg)
          end
        elsif expr.is_a?(Array)
          doc == expr
        else
          doc.include?(expr)
        end
      end

      def self.resolve_op(query, id, doc, op, arg)
        case op
        when '$eq'
          if arg.is_a?(Array)
            doc == arg
          else
            doc.include?(arg)
          end
        when '$gt'
          doc > arg
        when '$gte'
          doc >= arg
        when '$in'
          (arg & doc).present?
        when '$lt'
          doc < arg
        when '$lte'
          doc <= arg
        when '$ne'
          if arg.is_a?(Array)
            doc != arg
          else
            !doc.include?(arg)
          end
        when '$nin'
          (arg & doc).empty?
        else
          raise StandardError.new("In query #{query.inspect}, don't know how to handle #{op} => #{arg} for #{id} => #{doc}")
        end
      end
    end
  end
end
