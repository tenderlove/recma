module RKelly
  module JS
    class Object < Base
      attr_reader :value
      class << self
        def create(*args)
          arg = args.first
          return self.new if arg.nil? || arg == :undefined
          case arg
          when true, false
            JS::Boolean.new(arg)
          end
        end
      end

      def initialize(*args)
        super()
        self['prototype'] = JS::ObjectPrototype.new
        self['Class'] = 'Object'
        if args.first.nil?
          self['valueOf'] = lambda { self }
        end
      end
    end
  end
end
