module RKelly
  class Token
    attr_accessor :name, :value, :transformer
    def initialize(name, value, &transformer)
      @name         = name
      @value        = value
      @transformer  = transformer
    end

    def to_racc_token
      return transformer.call(name, value) if transformer
      [name, value]
    end
  end
end
