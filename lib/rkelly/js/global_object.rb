module RKelly
  module JS
    class GlobalObject < Base
      def initialize
        super
        self['class']     = 'GlobalObject'
        self['NaN']       = 0.0 / 0.0
        self['NaN'].attributes << :dont_enum
        self['NaN'].attributes << :dont_delete
        self['Object'] = JS::Object.new
        self['Object'].function = lambda { |*args|
          JS::Object.create(*args)
        }
      end
    end
  end
end
