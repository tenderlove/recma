module RKelly
  module JS
    class GlobalObject
      attr_reader :properties
      def initialize
        @properties = {}
        self['prototype'] = nil
        self['class']     = 'GlobalObject'
      end

      def [](name)
        return self.properties[name] if has_property?(name)
        if self.properties['prototype'] && self.properties['prototype'].value
          self.properties['prototype'].value[name]
        else
          RKelly::Runtime::UNDEFINED
        end
      end

      def []=(name, value)
        return unless can_put?(name)
        if has_property?(name)
          self.properties[name].value = value
        else
          self.properties[name] = Property.new(name, value)
        end
      end

      def can_put?(name)
        if !has_property?(name)
          return true if self.properties['prototype'].nil?
          return true if self.properties['prototype'].value.nil?
          return self.properties['prototype'].value.can_put?(name)
        end
        !self.properties[name].read_only?
      end

      def has_property?(name)
        return true if self.properties.has_key?(name)
        return false if self.properties['prototype'].nil?
        return false if self.properties['prototype'].value.nil?
        self.properties['prototype'].value.has_property?(name)
      end

      def delete(name)
        return true unless has_property?(name)
        return false if self.properties[name].dont_delete?
        self.properties.delete(name)
        true
      end
    end
  end
end
