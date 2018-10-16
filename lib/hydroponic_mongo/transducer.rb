class Transducer
  module Transformations
    extend self

    COMPACT = -> &reduce {
      -> result, input {
        if input.nil?
          result
        else
          reduce.call(result, input)
        end
      }
    }

    def map(&fn)
      -> &reduce {
        -> result, input {
          reduce.call(result, fn.call(input))
        }
      }
    end

    def filter(&fn)
      -> &reduce {
        -> result, input {
          if fn.call(input)
            reduce.call(result, input)
          else
            result
          end
        }
      }
    end

    def reject(&fn)
      filter {|item| !fn.call(item)}
    end

    def compact
      COMPACT
    end
  end

  class Reducer
    def push
      [[], -> list, item {list.push(item)}]
    end

    def sum(initial = 0)
      [initial, -> sum, item { sum += item }]
    end

    def count
      [0, -> sum, _ { sum += 1 }]
    end

    def any?(&fn)
      [false, -> _, item {
        break true if (fn ? fn.call(item) : item)
        false
      }]
    end

    def none?(&fn)
      [false, -> _, item {
        break false if (fn ? fn.call(item) : item)
        true
      }]
    end

    def all?(&fn)
      [true, -> result, item {
        break false if !(fn ? fn.call(item) : item)
        true
      }]
    end

    def one?(&fn)
      [false, -> one, item {
        if (fn ? fn.call(item) : item)
          break false if one
          true
        else
          one
        end
      }]
    end

    def find(ifnone = nil, &fn)
      [ifnone, -> ifnone, item {
        break item if (fn ? fn.call(item) : item)
        ifnone
      }]
    end
  end

  class << self
    def eval(enum, &block)
      evaluator = new
      evaluator.instance_exec(&block)
      if !evaluator.reduced
        evaluator.send(:reduce, :push)
      end
      enum.reduce evaluator.initial, &compose(evaluator.operations)
    end

    def compose(operations)
      first, *operations = operations
      if operations.count > 0
        first.call(&compose(operations))
      else
        first
      end
    end
  end

  attr_reader :operations, :reduced, :initial

  private
  def initialize
    @reduced = false
    @operations = []
  end

  def map(&block)
    @operations.push(Transformations.map(&block))
  end

  def filter(&block)
    @operations.push(Transformations.filter(&block))
  end

  def reject(&block)
    @operations.push(Transformations.reject(&block))
  end

  def compact
    @operations.push(Transformations::COMPACT)
  end

  def reduce(type = nil)
    @reduced = true
    if block_given?
      @initial, reducer = Reducer.new.instance_exec(&Proc.new)
    elsif type
      @initial, reducer = Reducer.new.public_send(type)
    else
      raise ArgumentError.new("reduce expects a type or a block")
    end
    @operations.push(reducer)
  end
end

module Enumerable
  def transduce(&block)
    Transducer.eval(self, &block)
  end
end

