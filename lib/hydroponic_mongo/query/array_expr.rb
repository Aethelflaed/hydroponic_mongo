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

      define_method('$size') do |doc, arg|
        doc.size == arg
      end

      define_method('$elemMatch') do |doc, arg|
        if arg.keys.first.start_with?('$')
          doc = doc.each_with_index.map{|o, i| [i, {'_' => o}]}
          arg = {'_' => arg}
        else
          doc = doc.each_with_index.map{|o, i| [i, o]}
        end

        transducer = Query.new(arg, doc).new_transducer

        transducer.reduce :any?
      end
    end
  end
end
