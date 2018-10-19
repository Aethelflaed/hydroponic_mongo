# frozen_string_literal: true

require 'hydroponic_mongo/query/logical'

module HydroponicMongo
  class Query
    include Query::Logical

    attr_reader :expressions
    attr_reader :collection
    attr_reader :options
    attr_reader :position

    def initialize(expressions, collection, options = {})
      @expressions = expressions
      @collection = collection
      @options = options
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

    def documents
      transducer = nil

      if expressions.empty?
        transducer = Transducer.new(collection.documents.values)
      elsif expressions.size == 1 && expressions.key?('_id')
        transducer = Transducer.new([collection.documents[expressions['_id']]])
        transducer.compact
      else
        transducer = Transducer.new(collection.documents)

        expressions.each do |expression|
          if (matcher = factory(*expression))
            transducer.filter(&matcher)
          end
        end

        # Keep only the document
        transducer.map{|id, doc| doc}
      end

      if (sort = options['sort'])
        transducer = transducer.reduce do
          sort do |a, b|
            value = sort.each do |key, dir|
              value = if dir > 0
                        a[key] <=> b[key]
                      else
                        b[key] <=> a[key]
                      end

              break value if value != 0
            end

            value.is_a?(Hash) ? 0 : value
          end
        end
      end
      transducer.to_a
    end

    def factory(key, value)
      case key
      when '$and'
        and_expressions(value)
      when '$nor'
        nor_expressions(value)
      when '$or'
        or_expressions(value)
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
          set_position(doc.each_with_index.find_index do |sub_doc, i|
            evaluate_expression(i, sub_doc, expr, path)
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

require 'hydroponic_mongo/query/value_expr'
require 'hydroponic_mongo/query/array_expr'
require 'hydroponic_mongo/query/hash_expr'

