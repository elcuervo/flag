module Flag
  KEY = "_flag".freeze

  class Feature
    attr_reader :feature, :active, :key

    def initialize(feature)
      @feature = feature
      @key = "#{Flag::KEY}:#{feature}"
      @enabled_for = []
      @active = false
    end

    def reset
      @enabled_for = []
    end

    def off?; !active? end

    def on?(what = false)
      if what
        return true if @enabled_for.include?(what)

        if [Integer, Fixnum, String].include?(what.class)
          groups = @enabled_for.select { |i| i.is_a?(Symbol) }
          groups.any? { |g| Flag.group[g].call(what) }
        else
          false
        end
      else
        !!active
      end
    end

    def off!
      @active = false
    end

    def on!(what = false)
      if what
        @enabled_for << what
      else
        @active = true
      end
    end
  end

  class << self
    attr_accessor :store

    def flush
      features.each { |_, f| f.reset }
    end

    def keys
      features.reject { |_, v| !v.on? }.keys
    end

    def groups
      group.keys
    end

    def group
      @_group ||= Hash.new
    end

    def features
      @_features ||= Hash.new { |h, k| h[k] = Feature.new(k) }
    end
  end
end

def Flag(feature); Flag.features[feature] end
