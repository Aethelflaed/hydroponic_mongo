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
        break true if fn.call(item)
        false
      }]
    end

    def none?(&fn)
      [false, -> _, item {
        break false if fn.call(item)
        true
      }]
    end

    def all?(&fn)
      [true, -> result, item {
        break false if !fn.call(item)
        true
      }]
    end

    def one?(&fn)
      [false, -> one, item {
        if fn.call(i)
          break false if one
          true
        else
          one
        end
      }]
    end

    def find(ifnone = nil, &fn)
      [ifnone, -> ifnone, item {
        break item if fn.call(item)
        ifnone
      }]
    end
  end

  class << self
    def eval(enum, &block)
      evaluator = new
      initial = evaluator.instance_exec(&block)
      if !evaluator.instance_variable_get('@reduced')
        initial = evaluator.send(:reduce, :push)
      end
      enum.reduce initial, &compose(evaluator.operations)
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

  attr_reader :operations

  private
  def initialize
    @operations = []
  end

  def map(&block)
    @operations.push(Transformations.map(&block))
    nil
  end

  def filter(&block)
    @operations.push(Transformations.filter(&block))
    nil
  end

  def reject(&block)
    @operations.push(Transformations.reject(&block))
    nil
  end

  def compact
    @operations.push(Transformations::COMPACT)
    nil
  end

  def reduce(type = nil)
    @reduced = true
    if block_given?
      initial, reducer = Reducer.new.instance_exec(&Proc.new)
    else
      initial, reducer = Reducer.new.public_send(type)
    end
    @operations.push(reducer)
    return initial
  end
end

module Enumerable
  def transduce(&block)
    Transducer.eval(self, &block)
  end
end

