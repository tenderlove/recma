module RKelly
  module JS
    class GlobalObject < Base
      def initialize
        super
        self['prototype'] = nil
        self['class']     = 'GlobalObject'
        self['NaN']       = 0.0 / 0.0
        self['NaN'].attributes << :dont_enum
        self['NaN'].attributes << :dont_delete
        self['Object'] = lambda { |*args|
          JS::Object.create(*args)
        }
      end
    end
  end
end
