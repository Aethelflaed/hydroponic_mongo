# frozen_string_literal: true

require 'hydroponic_mongo/query/logical'

module HydroponicMongo
  class Query
    include Query::Logical

    attr_reader :expressions
    attr_reader :options
    attr_reader :position

    def initialize(expressions, documents, options = {})
      @expressions = expressions
      @documents = documents
      @options = options
      @position = nil
    end

    def new_transducer
      transducer = Transducer.new(@documents)

      expressions.each do |expression|
        if (matcher = factory(*expression))
          transducer.filter(&matcher)
        end
      end

      transducer
    end

    def documents
      transducer = new_transducer
      # Keep only the document
      transducer.map{|id, doc| doc}

      if (sort_fields = options['sort'])
        transducer = transducer.reduce do
          sort do |a, b|
            value = sort_fields.each do |key, dir|
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
      result = transducer.to_a

      if options['skip']
        if options['skip'] > result.count
          result = []
        else
          result = result[options['skip']..-1]
        end
      end

      if options['limit'] && options['limit'] > 0
        result = result[0..options['limit']]
      end

      return result
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
        evaluate(id, doc, expr, field_name.split('.', -1))
      }
    end

    def evaluate(id, doc, expr, path)
      first, *rest = path

      case doc
      when Hash
        if first.nil?
          return HashExpr.resolve(self, doc, expr)
        elsif doc.key?(first)
          return evaluate(first, doc[first], expr, rest)
        else
          return evaluate(first, nil, expr, [])
        end

      when Array
        index = first.to_i if first.to_i.to_s == first
        if first.nil?
          return ArrayExpr.resolve(self, doc, expr)
        elsif index
          return evaluate(index, doc[index], expr, rest)
        else
          # search in array and set position if needed
          position = doc.each_with_index.find_index do |sub_doc, i|
            evaluate(i, sub_doc, expr, path)
          end
          # The first found position is stored, it may be used in an update
          # operation in place of the position operator $
          if position && @position.nil?
            @position = position
          end
          return position
        end

      else
        if first.nil?
          return ValueExpr.resolve(self, doc, expr)
        else
          check_nonexistent_or_negative(expr)
        end
      end
    end

    def check_nonexistent_or_negative(expr)
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

require 'hydroponic_mongo/query/value_expr'
require 'hydroponic_mongo/query/array_expr'
require 'hydroponic_mongo/query/hash_expr'

