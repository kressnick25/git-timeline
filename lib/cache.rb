# a simple in-memory cache, default TTL is 12 hours
# usage:
# c = Cache.new
# def wrap_expensive_method(param)
#   c.fetch "key" do
#     expensive_method(param1)
#   end
# end
class Cache
  def initialize(ttl = 43_200)
    @store = {}
    @ttl = ttl
  end

  def fetch(key, &block)
    if @store.key?(key) && !@store[key].expired
      # exists, retrieve & return
      @store[key].data
    elsif block_given?
      # execute code block, store & return
      data = yield(block)
      @store[key] = CachedData.new(data, @ttl)
      data
    end
  end
end

# A value stored in the cache
class CachedData
  attr_accessor :data

  def initialize(data, ttl)
    @data = data
    @ttl = ttl
    @created_at = Time.new
  end

  def expired
    now = Time.new
    difference = now - @created_at
    difference >= @ttl
  end
end
