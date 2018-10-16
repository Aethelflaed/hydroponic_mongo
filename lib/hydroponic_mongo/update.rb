# frozen_string_literal: true

module HydroponicMongo
  module Update
    def self.apply(document, update, options)
      modified = false

      update.each do |op, values|
        modified ||= apply_op(document, op, values, options)
      end

      return modified
    end

    def self.apply_op(document, op, values, options)
      modified = false

      case op
      when '$set'
        values.each do |k, v|
          modified ||= (document[k] != document[k] = v)
        end
      when '$inc'
        values.each do |k, v|
          document.key?(k) ?
            document[k] += v :
            document[k] = v
          modified = true
        end
      when '$currentDate'
        # check the date format before implementing...
        raise NotImplementedError.new
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
      else
        raise NotImplementedError.new("Not implemented update operator #{op}")
      end

      return modified
    end
  end
end
