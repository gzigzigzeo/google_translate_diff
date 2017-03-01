class GoogleTranslateDiff::RedisCacheStore
  extend Dry::Initializer::Mixin

  param :connection_pool

  option :timeout, default: proc { 60 * 60 * 24 * 7 }

  def read_multi(keys)
    EbayMag2.redis { |redis| redis.mget(*keys) }
  end

  def write(key, value)
    EbayMag2.redis { |redis| redis.setex(key, timeout, value) }
  end
end
