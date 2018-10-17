# frozen_string_literal: true

class Transducer
  # Transformations groups transformations lambdas, which compose the
  # different operations of the transducer before the reducing phase.
  #
  # The methods should return a lambda taking the next reducer as a block
  # parameter, which should itself return a reducing lambda, generally
  # calling the first lambda's reducer parameter as needed.
  module Transformations
    extend self

    def map(&fn)
      -> &reducer {
        -> result, input {
          reducer.call(result, fn.call(input))
        }
      }
    end

    def filter(&fn)
      -> &reducer {
        -> result, input {
          if fn.call(input)
            reducer.call(result, input)
          else
            result
          end
        }
      }
    end

    def reject(&fn)
      filter {|item| !fn.call(item)}
    end

    def unwind(&fn)
      -> &reducer {
        -> result, input {
          fn.call(input) do |item|
            result = reducer.call(result, item)
          end
          result
        }
      }
    end

    def flatten(level = nil)
      -> &reducer {
        -> result, input {
          [input].flatten(level).each do |item|
            result = reducer.call(result, item)
          end

          result
        }
      }
    end

    def compact
      -> &reducer {
        -> result, input {
          if input.nil?
            result
          else
            reducer.call(result, input)
          end
        }
      }
    end
  end
end
