# frozen_string_literal: true

module HydroponicMongo
  class Query
    module ValueExpr
      def self.resolve(query, id, doc, expr)
        if expr.is_a?(Hash) && expr.keys.first[0] == '$'
          expr.all? do |op, arg|
            resolve_op(query, id, doc, op, arg)
          end
        else
          doc == expr
        end
      end

      def self.resolve_op(query, id, doc, op, arg)
        case op
        when '$eq'
          doc == arg
        when '$gt'
          doc > arg
        when '$gte'
          doc >= arg
        when '$in'
          arg.include?(doc)
        when '$lt'
          doc < arg
        when '$lte'
          doc <= arg
        when '$ne'
          doc != arg
        when '$nin'
          !arg.include?(doc)
        when '$exists'
          true
        end
      end
    end
  end
end
