module RKelly
  class Runtime
    class Reference < Struct.new(:name, :value)
    end
    class Scope
      attr_reader :properties
      attr_reader :return
      def initialize
        @properties = Hash.new { |h,k| h[k] = Reference.new(k, :undefined) }
        @return     = nil
        @returned   = false
      end

      def return=(value)
        @returned = true
        @return = value
      end

      def returned?; @returned; end
    end
  end
end
