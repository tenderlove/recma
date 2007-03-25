class RKelly
  class Token
    attr_accessor :type, :value, :start, :end, :lineno, :assignOp
    def initialize
      @type = @value = @start = @end = @lineno = @assignOp = nil
    end
  end
end
