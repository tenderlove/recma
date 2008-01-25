module RKelly
  module Nodes
    class ResolveNode < Node
      def ==(other)
        return true if super
        if @value =~ /^[A-Z]/
          klass = [Object, Module].find { |x| x.const_defined?(@value.to_sym) }
          return true if klass && other.value.is_a?(klass)
        end
        false
      end
      alias :=~ :==
    end
  end
end
