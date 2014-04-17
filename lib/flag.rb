module Flag
  class Feature
    attr_reader :feature, :active

    def initialize(feature)
      @feature = feature
      @active = false
    end

    def active?
      !!active
    end

    def off!;
      @active = false
    end

    def on!
      @active = true
    end
  end

  class << self
    def keys
      features.reject { |_, v| !v.active? }.keys
    end

    def features
      @_features ||= Hash.new { |h, k| h[k] = Feature.new(k) }
    end
  end
end

def Flag(feature)
  Flag.features[feature]
end
