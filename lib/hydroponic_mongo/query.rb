# frozen_string_literal: true

module HydroponicMongo
  class Query
    def initialize(query)
      @query = query
    end

    def empty?
      @query.size == 0
    end

    def id?
      @query.size == 1 && @query.key?('_id')
    end

    def id
      @query['_id']
    end

    def each
      @query.each do |criterion|
        yield factory(*criterion)
      end
    end

    def factory(key, value)
      case key
      when '$or'
      when '$and'
      else
        case value
        when Hash
          -> (id, doc) {
            Operator.to_proc(self, key, value).call(id, doc, key)
          }
        else
          -> (id, doc) {
            resolve_field_name(doc, key)[1] == value
          }
        end
      end
    end

    def resolve_field_name(doc, name)
      resolve_field_path(doc, *name.split('.'))
    end

    def resolve_field_path(doc, first, *rest)
      case doc
      when Hash
        if doc.key?(first)
          if rest.count == 0
            return [true, doc[first]]
          else
            return resolve_field_path(doc[first], *rest)
          end
        end
      when Array
        if first.to_i.to_s == first
          if rest.count == 0
            return [true, doc[first.to_i]]
          else
            return resolve_field_path(doc[first.to_i], *rest)
          end
        else
          rest.unshift first
          query = Query.new(*rest)
          resolver = ->(value) {
            resolve_field_path(value, *rest)
          }
          rval, @position = Transducer.eval(doc.each_with_index) do
            # Invert value and index order
            map{|value, id| [id, value]}
            map{|id, value| [resolver.call(value), index]}
            reduce do
              find{|value, index| value[0]}
            end
          end
          binding.pry
          return rval
        end
      end

      return [false, false]
    end
  end
end

require 'hydroponic_mongo/query/operator'

