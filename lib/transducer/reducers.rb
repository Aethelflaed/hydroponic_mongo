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

    # Create a new array containing each reduced element if it's not already
    # present in the array
    #
    # Aliased as :distinct
    def uniq
      [[], -> list, item {
        list.push(item) if !list.include?(item)
        list
      }]
    end
    alias_method :distinct, :uniq

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

    def sort(&fn)
      [[], -> result, item {
        if fn
          insert_sorted_fn(result, item, 0, result.size, fn)
        else
          insert_sorted(result, item, 0, result.size)
        end
      }]
    end

    def sort_by(&fn)
      [[], -> result, item {
        insert_sorted_fn(result,
                         [fn.call(item), item],
                         0, result.size,
                         -> a, b { a[0] <=> b[0] })
      }, -> array {
        array.map {|sort_key, item| item}
      }]
    end

    private
    def insert_sorted(array, item, from, to)
      if (size = to - from) == 0
        array.insert(from, item)
      else
        half = from + size / 2
        res = item <=> array[half]
        if half == from
          if res <= 0
            array.insert(from, item)
          else
            array.insert(from + 1, item)
          end
        else
          if res < 0
            insert_sorted(array, item, from, half)
          elsif res > 0
            insert_sorted(array, item, half, to)
          else
            array.insert(half, item)
          end
        end
      end

      return array
    end

    def insert_sorted_fn(array, item, from, to, fn)
      if (size = to - from) == 0
        array.insert(from, item)
      else
        half = from + size / 2
        res = fn.call(item, array[half])
        if half == from
          if res <= 0
            array.insert(from, item)
          else
            array.insert(from + 1, item)
          end
        else
          if res < 0
            insert_sorted_fn(array, item, from, half, fn)
          elsif res > 0
            insert_sorted_fn(array, item, half, to, fn)
          else
            array.insert(half, item)
          end
        end
      end

      return array
    end
  end
end
