module Flag
  FEATURES = "_flag:features".freeze

  Members = Struct.new(:name) do
    USERS = "users".freeze
    GROUPS = "groups".freeze

    def <<(item)
      Flag.store.call("SADD", subkey(item), item)
    end

    def key
      "#{Flag::FEATURES}:#{name}"
    end

    def groups
      list = Flag.store.call("SMEMBERS", "#{key}:#{GROUPS}") || []
      list.map(&:to_sym)
    end

    def include?(item)
      Flag.store.call("SISMEMBER", subkey(item), item).to_i == 1
    end

    def reset!
      [USERS, GROUPS].each do |k|
        Flag.store.call("DEL", "#{key}:#{k}")
      end
    end

    private

    def subkey(item)
      "#{key}:#{subgroup(item)}"
    end

    def subgroup(item)
      case item
      when Integer, Fixnum, String then USERS
      when Symbol then GROUPS
      end
    end
  end

  class Feature
    attr_accessor :active
    attr_reader   :name

    def initialize(name)
      @name = name
      @members = Members.new(name)
    end

    def key
      @members.key
    end

    def reset
      @members.reset!
    end

    def off?; !active? end

    def on?(what = false)
      return active? if !what
      return true if @members.include?(what)

      if [Integer, Fixnum, String].include?(what.class)
        @members.groups.any? { |g| Flag.group[g].call(what) }
      else
        false
      end
    end

    def off!
      Flag.store.call("HSET", Flag::FEATURES, name, 0)
    end

    def on!(what = false)
      if what
        @members << what
      else
        Flag.store.call("HSET", Flag::FEATURES, name, 100)
      end
    end

    private

    def active?
      Flag.store.call("HGET", FEATURES, name).to_i == 100
    end
  end

  class << self
    attr_accessor :store

    def flush
      features.each { |_, f| f.reset }
      self.store.call("DEL", FEATURES)
    end

    def keys
      features.select { |k, v| k if v.on? }.keys
    end

    def groups
      group.keys
    end

    def group
      @_group ||= Hash.new
    end

    def features
      @_features ||= Hash.new { |h, k| h[k] = Feature.new(k) }

      self.store.call("HGETALL", FEATURES).each_slice(2) do |slice|
        @_features[slice.first.to_sym]
      end

      @_features
    end
  end
end

def Flag(feature); Flag.features[feature] end
