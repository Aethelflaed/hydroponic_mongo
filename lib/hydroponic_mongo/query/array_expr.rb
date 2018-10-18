# frozen_string_literal: true

module HydroponicMongo
  class Query
    module ArrayExpr
      include ValueExpr
      extend self

      define_method('$eq') do |doc, arg|
        if arg.is_a?(Array)
          doc == arg
        else
          doc.include?(arg)
        end
      end

      define_method('$ne') do |doc, arg|
        if arg.is_a?(Array)
          doc != arg
        else
          !doc.include?(arg)
        end
      end

      define_method('$in') do |doc, arg|
        (doc & arg).present?
      end

      define_method('$nin') do |doc, arg|
        (doc & arg).empty?
      end
    end
  end
end
