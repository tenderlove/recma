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

      def has_property?(name)
        return true if self.properties.has_key?(name)
      end

      def [](name)
        return self.properties[name] if has_property?(name)
        RKelly::Runtime::UNDEFINED
      end

      def return=(value)
        @returned = true
        @return = value
      end

      def returned?; @returned; end
    end
  end
end
