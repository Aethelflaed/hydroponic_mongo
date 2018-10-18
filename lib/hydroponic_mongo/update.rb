# frozen_string_literal: true

module HydroponicMongo
  module Update
    def self.apply(document, update, options)
      modified = false

      update.each do |op, values|
        modified = apply_op(document, op, values, options) || modified
      end

      return modified
    end

    def self.apply_op(document, op, values, options)
      modified = false

      case op
      when '$set'
        values.each do |k, v|
          modified = (document[k] != (document[k] = v)) || modified
        end
      when '$inc'
        values.each do |k, v|
          document.key?(k) ?
            document[k] += v :
            document[k] = v
          modified = true
        end
      when '$min'
        values.each do |k, v|
          if !document.key?(k) || v < document[k]
            document[k] = v
            modified = true
          end
        end
      when '$max'
        values.each do |k, v|
          if !document.key?(k) || v > document[k]
            document[k] = v
            modified = true
          end
        end
      when '$rename'
        values.each do |k, v|
          if document.key?(k)
            document[v] = document.delete(k)
            modified = true
          end
        end
      when '$unset'
        values.each do |k, _|
          if document.key?(k)
            document.delete(k)
            modified = true
          end
        end
      when '$push'
        values.each do |field, value|
          doc, key = resolve_field_path(document, field, field.split('.', -1))
          if !doc.key?(key)
            doc[key] = []
          end
          if !doc[key].is_a?(Array)
            raise WriteError.new(16837, "The field '#{field}' must be an array but if of type #{doc[key].class} in document {_id: #{document['_id']}}")
          end

          if value.is_a?(Hash) && value.keys.first[0] == '$'
            raise NotImplementedError.new("$push with modifiers not yet implemented")
          else
            doc[key].push(value)
          end
        end

      when '$currentDate'
        raise NotImplementedError.new("Need to check the date format before implementing $currentDate")
      else
        raise NotImplementedError.new("Not implemented update operator #{op}")
      end

      return modified
    end

    def self.resolve_field_path(document, field, path)
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
