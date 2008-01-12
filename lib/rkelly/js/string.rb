module RKelly
  module JS
    class String < Base
      def initialize(value)
        super()
        self['valueOf'] = value
        self['valueOf'].function = lambda { value }
        self['toString'] = value
      end
    end
  end
end
