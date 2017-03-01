class GoogleTranslateDiff::RedisRateLimiter
  extend Dry::Initializer::Mixin

  param :connection_pool
  param :limit, default: proc { 8000 }

  option :namespace, default: proc { "google-translate-diff" }

end
