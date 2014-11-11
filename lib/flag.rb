require "zlib"
require "redic"

module Flag
  FEATURES = "_flag:features".freeze

  Members = Struct.new(:name) do
    USERS  = "users".freeze
    GROUPS = "groups".freeze

    def <<(item)
      if item.to_s.end_with?("%")
        Flag.store.call("HSET", Flag::FEATURES, name, item[0...-1])
      else
        Flag.store.call("SADD", subkey(item), item)
      end
    end

    def key
      "#{Flag::FEATURES}:#{name}"
    end

    def activated
      { percentage: percentage.to_i, users: users, groups: groups }
    end

    def groups; members_for(GROUPS).map(&:to_sym) end
    def users;  members_for(USERS) end

    def include?(item)
      return percentage == item[0...-1].to_i if item.to_s.end_with?("%")
      return true if Zlib.crc32(item.to_s) % 100 < percentage

      Flag.store.call("SISMEMBER", subkey(item), item).to_i == 1
    end

    def reset
      [USERS, GROUPS].each { |k| Flag.store.call("DEL", "#{key}:#{k}") }
    end

    private

    def members_for(type)
      Flag.store.call("SMEMBERS", "#{key}:#{type}") || []
    end

    def percentage
      Flag.store.call("HGET", Flag::FEATURES, name).to_i
    end

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

    def reset;     @members.reset     end
    def key;       @members.key       end
    def activated; @members.activated end

    def off?; !active? end

    def on?(what = false)
      return active? if !what
      return true    if @members.include?(what)

      case what
      when Integer, Fixnum, String
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
      @_group = nil
      features.each { |_, f| f.reset }
      self.store.call("DEL", FEATURES)
    end

    def enabled
      features.select { |k, v| v.on? }.keys
    end

    def store; @store  ||= Redic.new end
    def group; @_group ||= Hash.new { |h, k| h[k] = lambda { |id| } } end

    def groups; group.keys end

    def features
      @_features ||= Hash.new { |h, k| h[k] = Feature.new(k) }

      self.store.call("HKEYS", FEATURES).each { |k| @_features[k.to_sym] }

      @_features
    end
  end
end

def Flag(feature); Flag.features[feature] end
