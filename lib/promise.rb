
##
# A delayed-execution promise.  Promises are only executed once.
# @example
#     x = { factorial 20 }
#     y = { fibonacci 10**6 }
#     a = x + 1     # => factorial 20 + 1 after factorial calculates
#     result = promise { a += y }
#     abort ""      # whew, we never needed to calculate y
# @example
#     y = 5
#     x = promise { y = y + 5 }
#     x + 5     # => 15
#     x + 5     # => 15
class Promise

  instance_methods.each { |m| undef_method m unless m =~ /__/ }
  attr_reader :result

  # Returns a new promise
  # @param [Proc] block
  # @return [Promise]
  def initialize(block)
    if block.arity > 0
      raise ArgumentError, "Cannot store a promise that requires an argument"
    end
    @block = block
    @mutex = Mutex.new
  end

  # Force the evaluation of this promise immediately
  # @return [Any]
  def force
    @mutex.synchronize do 
      unless @result
        @result = @block.call
      end
    end
    @result
  end

  def method_missing(method, *args, &block)
    force unless @result
    @result.send(method, *args, &block)
  end
end

module Kernel

  def promise(&block)
    Promise.new(block)
  end

end