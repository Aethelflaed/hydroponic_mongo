# frozen_string_literal: true

require 'transducer/transformations'
require 'transducer/reducers'

class Transducer
  AlreadyReducedError = Class.new(StandardError) do
    def initialize
      super("The transducer has already been reduced")
    end
  end

  def self.eval(enum, &block)
    new(enum).eval(&block)
  end

  def initialize(enum)
    @enum = enum
    @operations = []
    @reduced = false
  end

  def eval(&block)
    raise AlreadyReducedError.new if @reduced
    instance_exec(&block)
  end

  def map(&block)
    raise AlreadyReducedError.new if @reduced
    @operations.push(Transformations.map(&block))
    self
  end

  def filter(&block)
    raise AlreadyReducedError.new if @reduced
    @operations.push(Transformations.filter(&block))
    self
  end
  alias_method :select, :filter

  def reject(&block)
    raise AlreadyReducedError.new if @reduced
    @operations.push(Transformations.reject(&block))
    self
  end

  def compact
    raise AlreadyReducedError.new if @reduced
    @operations.push(Transformations.compact)
    self
  end

  def flatten(level = nil)
    raise AlreadyReducedError.new if @reduced
    @operations.push(Transformations.flatten(level))
    self
  end

  def unwind(&block)
    raise AlreadyReducedError.new if @reduced
    @operations.push(Transformations.unwind(&block))
    self
  end

  def reduce(type = nil, *args)
    raise AlreadyReducedError.new if @reduced
    @reduced = true
    if block_given?
      initial, reducer = Reducers.instance_exec(&Proc.new)
    elsif type
      args.unshift type
      initial, reducer = Reducers.public_send(*args)
    else
      raise ArgumentError.new("reduce expects a type or a block")
    end

    @operations.push(reducer)

    catch :break do
      @enum.reduce initial, &compose(@operations)
    end
  end

  def to_a
    reduce(:push)
  end

  private
  def compose(operations)
    first, *operations = operations
    if operations.count > 0
      first.call(&compose(operations))
    else
      first
    end
  end
end
