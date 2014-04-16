module Flag
  Feature = Struct.new(:feature) do
    def off!
      Flag.features.delete(feature)
    end

    def on!
      Flag.features[feature]
    end
  end

  class << self
    def keys
      features.keys
    end

    def features
      @_features ||= Hash.new { |h, k| h[k] = Feature.new(k) }
    end
  end
end

def Flag(feature)
  Flag.features[feature]
end
