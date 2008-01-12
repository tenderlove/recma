module RKelly
  module JS
    class Number < Base
      def initialize(value = 0)
        super()
        self['valueOf'] = value
        self['valueOf'].function = lambda { value }
        self['toString'] = value.to_s
      end
    end
  end
end
