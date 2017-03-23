require "zlib"
require "redic"

module Flag
  FEATURES = "_flag:features".freeze

  Members = Struct.new(:name) do
    USERS  = "users".freeze
    GROUPS = "groups".freeze

    def <<(item)
      Flag.execute do |store|
        if item.to_s.end_with?("%")
          store.call("HSET", Flag::FEATURES, name, item[0...-1])
        else
          store.call("SADD", subkey(item), item)
        end
      end
    end

    def key
      "#{Flag::FEATURES}:#{name}"
    end

    def activated
      { percentage: percentage, users: users, groups: groups }
    end

    def groups
      members_for(GROUPS).map(&:to_sym)
    end

    def users
      members_for(USERS)
    end

    def include?(item)
      return percentage == item.to_i if item.to_s.end_with?("%")
      return true if Zlib.crc32(item.to_s) % 100 < percentage

      Flag.execute do |store|
        store.call("SISMEMBER", subkey(item), item).to_i == 1
      end
    end

    def reset
      [USERS, GROUPS].each do |k|
        Flag.execute { |store| store.call("DEL", "#{key}:#{k}") }
      end
    end

    def percentage
      Flag.execute { |store| store.call("HGET", Flag::FEATURES, name).to_i }
    end

    private

    def members_for(type)
      Flag.execute do |store|
        store.call("SMEMBERS", "#{key}:#{type}") || []
      end
    end

    def subkey(item)
      "#{key}:#{subgroup(item)}"
    end

    def subgroup(item)
      case item
      when Integer, Fixnum, String then USERS
      when Symbol                  then GROUPS
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

    def reset
      @members.reset
    end

    def key
      @members.key
    end

    def activated
      @members.activated
    end

    def off?
      !active?
    end

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
      @members << "0%"
    end

    def on!(what = "100%")
      @members << what
    end

    private

    def active?
      @members.percentage == 100
    end
  end

  class << self
    attr_accessor :store

    def flush
      @_group = nil
      features.each { |_, f| f.reset }
      self.execute { |store| store.call("DEL", FEATURES) }
    end

    def enabled
      features.select { |k, v| v.on? }.keys
    end

    def quiet!
      @_quiet = true
    end

    def execute
      yield(store)
    rescue Errno::ECONNREFUSED, Errno::EINVAL => e
      raise e unless @_quiet
    end

    def store
      @store ||= Redic.new
    end

    def group
      @_group ||= Hash.new do |h, k|
        h[k] = lambda { |id| }
      end
    end

    def groups
      group.keys
    end

    def features
      @_features ||= Hash.new { |h, k| h[k] = Feature.new(k) }

      self.execute do |store|
        store.call("HKEYS", FEATURES).each { |k| @_features[k.to_sym] }
      end

      @_features
    end
  end
end

def Flag(feature)
  Flag.features[feature]
end
