class GoogleTranslateDiff::RedisRateLimiter
  extend Dry::Initializer::Mixin

  class RateLimitExceeded < StandardError; end

  param :connection_pool
  param :threshold, default: proc { 8000 }
  param :interval,  default: proc { 60 }

  option :namespace, default: proc { GoogleTranslateDiff::CACHE_NAMESPACE }

  def check(size)
    connection_pool.with do |redis|
      rate_limit = Ratelimit.new(namespace, redis: redis)
      if rate_limit.exceeded?("call", threshold: threshold, interval: interval)
        raise RateLimitExceeded
      end
      rate_limit.add size
    end
  end
end
