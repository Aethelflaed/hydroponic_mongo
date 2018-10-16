# frozen_string_literal: true

module HydroponicMongo
  class Query
    attr_reader :position

    def initialize(expressions)
      @expressions = expressions
      @position = nil
    end

    # Set @position if not already set, will be used
    # to replace a positional operator
    def set_position(position)
      if position && @position.nil?
        @position = position
      end

      return position
    end

    def empty?
      @expressions.size == 0
    end

    def id?
      @expressions.size == 1 && @expressions.key?('_id')
    end

    def id
      @expressions['_id']
    end

    def each
      @expressions.each do |expression|
        if (matcher = factory(*expression))
          yield matcher
        end
      end
    end

    def factory(key, value)
      case key
      when '$and'
        And.to_proc(self, value)
      when '$nor'
        Nor.to_proc(self, value)
      when '$or'
        Or.to_proc(self, value)
      when '$comment'
        # Ignore
      else
        expression(key, value)
      end
    end

    def expression(field_name, expr)
      -> ((id, doc)) {
        evaluate_expression(id, doc, expr, field_name.split('.', -1))
      }
    end

    def evaluate_expression(id, doc, expr, path)
      first, *rest = path

      case doc
      when Hash
        if first.nil?
          return HashExpr.resolve(self, id, doc, expr)
        elsif doc.key?(first)
          return evaluate_expression(first, doc[first], expr, rest)
        end
      when Array
        index = first.to_i if first.to_i.to_s == first
        if first.nil?
          return ArrayExpr.resolve(self, id, doc, expr)
        elsif index
          return evaluate_expression(index, doc[index], expr, rest)
        else
          # search in array and set_position
          set_position(doc.each_with_index.find_index do |sub_doc, index|
            evaluate_expression(index, sub_doc, expr, path)
          end)
        end
      else
        if first.nil?
          return ValueExpr.resolve(self, id, doc, expr)
        else
          case expr
          when Hash
            nonexistent = expr == {'$exists' => false} || expr == {'$not' => {'$exists' => true}}
            negative = expr.all? {|op, _| ['$not', '$nin', '$ne'].include?(op) }

            return nonexistent || negative
          else
            return false
          end
        end
      end
    end
  end
end

require 'hydroponic_mongo/query/and'
require 'hydroponic_mongo/query/or'
require 'hydroponic_mongo/query/nor'

require 'hydroponic_mongo/query/value_expr'
require 'hydroponic_mongo/query/array_expr'
require 'hydroponic_mongo/query/hash_expr'

