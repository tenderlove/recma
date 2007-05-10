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
      @__hash_values = JSObject.new
    end

    def []=(k, v)
      k.is_a?(Integer) ?  super(k, v) : @__hash_values.[]=(k, v)
    end

    def [](k)
      k.is_a?(Integer) ?  super(k) : @__hash_values.[](k)
    end

    def method_missing(sym, *args)
      @__hash_values.send(sym, *args)
    end
  end
end
