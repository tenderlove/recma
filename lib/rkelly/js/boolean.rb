module RKelly
  module JS
    class Boolean < Base
      def initialize(*args)
        super()
        self['valueOf'] = args.first
        self['valueOf'].function = lambda { args.first }
        self['toString'] = args.first.to_s
      end
    end
  end
end
