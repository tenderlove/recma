class RKelly
  class JSObject < OpenStruct
    def []=(k, v)
      self.send("#{k}=".intern, v)
    end

    def [](k)
      self.send(k.to_s.intern)
    end
  end

  class JSArray < Array
    def initialize(*args)
      super(*args)
      @__table = {}
    end

    def []=(k, v)
      if k.is_a?(Integer)
        super(k, v)
      else
        name = k.to_s.intern
        meta = class << self; self; end
        meta.send(:define_method, name) {
          @__table[name]
        }
        meta.send(:define_method, :"#{name}=") { |x|
          @__table[name] = x
        }
        @__table[name] = v
      end
    end

    def [](k)
      k.is_a?(Integer) ?  super(k) : self.send(k.to_s.intern)
    end
  end
end
