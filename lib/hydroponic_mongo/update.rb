# frozen_string_literal: true

module HydroponicMongo
  module Update
    extend self

    def apply(document, update, options)
      modified = false

      update.each do |op, values|
        if respond_to?(op)
          modified = public_send(op, document, values) || modified
        else
          raise NotImplementedError.new("Not implemented update operator #{op}")
        end
      end

      return modified
    end

    define_method('$set') do |document, values|
      modified = false
      values.each do |k, v|
        modified = (document[k] != (document[k] = v)) || modified
      end
      return modified
    end

    define_method('$inc') do |document, values|
      modified = false
      values.each do |k, v|
        document.key?(k) ?
          document[k] += v :
          document[k] = v
        modified = true
      end
      return modified
    end

    define_method('$min') do |document, values|
      modified = false
      values.each do |k, v|
        if !document.key?(k) || v < document[k]
          document[k] = v
          modified = true
        end
      end
      return modified
    end

    define_method('$max') do |document, values|
      modified = false
      values.each do |k, v|
        if !document.key?(k) || v > document[k]
          document[k] = v
          modified = true
        end
      end
      return modified
    end

    define_method('$rename') do |document, values|
      modified = false
      values.each do |k, v|
        if document.key?(k)
          document[v] = document.delete(k)
          modified = true
        end
      end
      return modified
    end

    define_method('$unset') do |document, values|
      modified = false
      values.each do |k, _|
        if document.key?(k)
          document.delete(k)
          modified = true
        end
      end
      return modified
    end

    define_method('$push') do |document, values|
      modified = false
      values.each do |field, value|
        doc, key = resolve_field_path(document, field, field.split('.', -1))
        if !doc.key?(key)
          doc[key] = []
        end
        if !doc[key].is_a?(Array)
          raise WriteError.new(16837, "The field '#{field}' must be an array but if of type #{doc[key].class} in document {_id: #{document['_id']}}")
        end

        if value.is_a?(Hash) && value.keys.first[0] == '$'
          original = doc[key].deep_dup

          if value['$each'].size > 0
            if value['$position']
              doc[key].insert(value['$position'], *value['$each'])
            else
              doc[key].push(*value['$each'])
            end
          end

          if (sort = value['$sort'])
            if sort.is_a?(Hash)
              k, dir = sort.first

              doc[key].sort_by!{|d| d[k]}
              if dir < 0
                doc[key].reverse!
              end
            else
              doc[key].sort!
              if sort < 0
                doc[key].reverse!
              end
            end
          end

          if (slice = value['$slice'])
            if slice == 0
              doc[key] = []
            elsif slice < 0
              doc[key] = doc[key].slice(slice..-1)
            else # slice > 0
              doc[key] = doc[key].slice(0, slice)
            end
          end

          modified = (original != doc[key]) || modified
        else
          modified = true
          doc[key].push(value)
        end
      end
      return modified
    end

    define_method('$addToSet') do |document, values|
      modified = false
      values.each do |field, value|
        doc, key = resolve_field_path(document, field, field.split('.', -1))
        if !doc.key?(key)
          doc[key] = []
        end
        if !doc[key].is_a?(Array)
          raise WriteError.new(16837, "The field '#{field}' must be an array but if of type #{doc[key].class} in document {_id: #{document['_id']}}")
        end

        if value.is_a?(Hash) && value.keys.first[0] == '$'
          value['$each'].each do |val|
            if !doc[key].include?(val)
              doc[key].push(val)
              modified = true
            end
          end
        elsif !doc[key].include?(value)
          doc[key].push(value)
          modified = true
        end
      end
      return modified
    end

    def resolve_field_path(document, field, path)
      first, *rest = path
      if rest.empty?
        return [document, first]
      else
        if document.key?(first)
          resolve_field_path(document[first], field, rest)
        else
          raise WriteError.new(56, "The update path '#{field}' contains an empty field name, which is not allowed.")
        end
      end
    end
  end
end
