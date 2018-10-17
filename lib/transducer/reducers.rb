# frozen_string_literal: true

class Transducer
  # Reducers groups actual reduce lambdas, i.e. lambdas which
  # actually reduce each successive element into a value.
  #
  # These methods each return an array containing the initial value
  # as the first element, and the reducing lambda as the second element.
  #
  # The initial may sometimes be provided as argument to the method.
  module Reducers
    extend self

    # Create a new array containing each reduced element.
    #
    # Aliased as :to_a
    def push
      [[], -> list, item {list.push(item)}]
    end
    alias_method :to_a, :push

    # Sum each reduced element.
    #
    # You can provide the initial value (defaults to 0).
    def sum(initial = 0)
      [initial, -> sum, item { sum += item }]
    end

    # Count the number of reduced element.
    def count
      [0, -> sum, _ { sum += 1 }]
    end

    # Passes each reduced element to the given block.
    # The method returns true if the block ever returns a value other than
    # false or nil.
    #
    # If the block is not given, returns true if a reduced element is truthy.
    def any?(&fn)
      [false, -> _, item {
        throw :break, true if (fn ? fn.call(item) : item)
        false
      }]
    end

    # Passes each reduced element to the given block.
    # The method returns false if the block ever returns a value other than
    # false or nil.
    #
    # If the block is not given, returns false if a reduced element is truthy.
    def none?(&fn)
      [false, -> _, item {
        throw :break, false if (fn ? fn.call(item) : item)
        true
      }]
    end

    # Passes each reduced element to the given block.
    # The method returns true if the block always returns a value other than
    # false or nil.
    #
    # If the block is not given, returns true if all reduced element are truthy.
    def all?(&fn)
      [true, -> _, item {
        throw :break, false if !(fn ? fn.call(item) : item)
        true
      }]
    end

    # Passes each reduced element to the given block.
    # The method returns true if the block returns a value other than
    # false or nil exactly one time.
    #
    # If the block is not given, returns true if only one reduced element
    # is truthy.
    def one?(&fn)
      [false, -> one, item {
        if (fn ? fn.call(item) : item)
          throw :break, false if one
          true
        else
          one
        end
      }]
    end

    # Passes each reduced element to the given block.
    # The method returns the first element for which the block returns a value
    # other than false or nil.
    #
    # If the block is not given, returns the first truthy element.
    #
    # If no element is found, returns +ifnone+ (defaults to nil)
    def find(ifnone = nil, &fn)
      [ifnone, -> _, item {
        throw :break, item if (fn ? fn.call(item) : item)
        _
      }]
    end
  end
end
