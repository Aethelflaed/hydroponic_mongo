# frozen_string_literal: true

module HydroponicMongo
  module Update
    extend self

    ArrayExpected = Class.new(StandardError)

    def apply(document, update, options)
      modified = false

      update.each do |op, values|
        if respond_to?(op)
          meth = method(op)
          values.each do |field, value|
            doc, key = resolve_field_path(document, field, field.split('.', -1), options)
            begin
              case meth.parameters.size
              when 3
                modified = meth.call(doc, key, value) || modified
              when 4
                modified = meth.call(doc, key, value, options) || modified
              end
            rescue ArrayExpected
              raise WriteError.new(16837, "The field '#{field}' must be an array but is of type #{doc[key].class} in document {_id: #{document['_id']}}")
            end
          end
        else
          raise UpdateOperatorNotImplementedError.new(op)
        end
      end

      return modified
    end

    define_method('$set') do |document, key, value|
      document[key] != (document[key] = value)
    end

    define_method('$setOnInsert') do |document, key, value, options|
      if options['upserting']
        document[key] = value
        true
      end
    end

    define_method('$inc') do |document, key, value|
      document.key?(key) ?
        document[key] += value :
        document[key] = value
      return true
    end

    define_method('$min') do |document, key, value|
      if !document.key?(key) || value < document[key]
        document[key] = value
        return true
      end
    end

    define_method('$max') do |document, key, value|
      if !document.key?(key) || value > document[key]
        document[key] = value
        return true
      end
    end

    define_method('$rename') do |document, key, value|
      if document.key?(key)
        document[value] = document.delete(key)
        return true
      end
    end

    define_method('$unset') do |document, key, _|
      if document.key?(key)
        document.delete(key)
        return true
      end
    end

    define_method('$push') do |document, key, value|
      if !document.key?(key)
        document[key] = []
      elsif !document[key].is_a?(Array)
        raise ArrayExpected.new
      end

      if value.is_a?(Hash) && value.keys.first[0] == '$'
        original = document[key].deep_dup

        if value['$each'].size > 0
          if value['$position']
            document[key].insert(value['$position'], *value['$each'])
          else
            document[key].push(*value['$each'])
          end
        end

        if (sort = value['$sort'])
          if sort.is_a?(Hash)
            k, dir = sort.first

            document[key].sort_by!{|d| d[k]}
            if dir < 0
              document[key].reverse!
            end
          else
            document[key].sort!
            if sort < 0
              document[key].reverse!
            end
          end
        end

        if (slice = value['$slice'])
          if slice == 0
            document[key] = []
          elsif slice < 0
            document[key] = document[key].slice(slice..-1)
          else # slice > 0
            document[key] = document[key].slice(0, slice)
          end
        end

        return (original != document[key])
      else
        document[key].push(value)
        return true
      end
    end

    define_method('$pushAll') do |document, key, value|
      public_send('$push', document, key, {'$each' => value})
    end

    define_method('$pull') do |document, key, value|
      if !document.key?(key)
        return false
      elsif !document[key].is_a?(Array)
        raise ArrayExpected.new
      end

      array = document[key]

      if value.is_a?(Hash)
        results = []
        if value.keys.first.start_with?('$')
          docs = array.each_with_index.map{|o, i| [i, {'_' => o}]}
          arg = {'_' => value}

          results = Query.new(arg, docs).new_transducer.map{|i, o| o['_']}.to_a
          results.each do |val|
            array.delete(val)
          end
        else
          docs = array.each_with_index.map{|o, i| [i, o]}
          arg = value

          results = Query.new(arg, docs).new_transducer.map{|i, o| o}.to_a
          results.each do |val|
            array.delete(val)
          end
        end

        return results.size > 0
      elsif array.include?(value)
        array.delete(value)
        return true
      else
        return false
      end
    end

    define_method('$pullAll') do |document, key, value|
      if !document.key?(key)
        return false
      elsif !document[key].is_a?(Array)
        raise ArrayExpected.new
      end

      modified = false

      value.each do |val|
        modified ||= document[key].include?(val)
        document[key].delete(val)
      end

      return modified
    end

    define_method('$addToSet') do |document, key, value|
      if !document.key?(key)
        document[key] = []
      elsif !document[key].is_a?(Array)
        raise ArrayExpected.new
      end

      if value.is_a?(Hash) && value.keys.first[0] == '$'
        modified = false
        value['$each'].each do |val|
          if !document[key].include?(val)
            document[key].push(val)
            modified = true
          end
        end

        return modified
      elsif !document[key].include?(value)
        document[key].push(value)
        return true
      end
    end

    def resolve_field_path(document, field, path, options = {})
      first, *rest = path
      if rest.empty?
        return [document, first]
      else
        if document.is_a?(Array)
          index = first.to_i if first.to_i.to_s == first
          if first == '$'
            index = options['position']
          end
          if index
            resolve_field_path(document[index], field, rest, options)
          else
            raise WriteError.new(16837, "cannot use '#{field}' to traverse the element")
          end
        elsif document.key?(first)
          resolve_field_path(document[first], field, rest, options)
        else
          raise WriteError.new(56, "The update path '#{field}' contains an empty field name, which is not allowed.")
        end
      end
    end
  end
end
