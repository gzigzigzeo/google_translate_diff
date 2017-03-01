class GoogleTranslateDiff::RedisCacheStore
  extend Dry::Initializer::Mixin

  param :connection_pool

  option :timeout, default: proc { 60 * 60 * 24 * 7 }
  option :namespace, default: proc { "google-translate-diff" }

  def read_multi(keys)
    redis { |redis| redis.mget(*keys) }
  end

  def write(key, value)
    redis { |redis| redis.setex(key, timeout, value) }
  end

  private

  def redis
    connection_pool.with do |redis|
      yield Redis::Namespace.new(namespace, redis: redis)
    end
  end
end
