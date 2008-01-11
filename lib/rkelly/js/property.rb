module RKelly
  module JS
    class Property
      attr_accessor :name, :value, :attributes, :function
      def initialize(name, value, function = nil, attributes = [])
        @name = name
        @value = value
        @function = function
        @attributes = attributes
      end

      [:read_only, :dont_enum, :dont_delete, :internal].each do |property|
        define_method(:"#{property}?") do
          self.attributes.include?(property)
        end
      end
    end
  end
end
