class GoogleTranslateDiff::Cache
  extend Dry::Initializer::Mixin

  param :from
  param :to

  def cached_and_missing(values)
    keys = values.map { |v| key(v) }
    pattern = cache_store.read_multi(keys)
    missing = values.map.with_index { |v, i| v if pattern[i].nil? }.compact

    [pattern, missing]
  end

  def store(values, cached, updates)
    values.map.with_index do |value, index|
      value || store_value(cached[index], updates.shift)
    end
  end

  private

  def store_value(value, translation)
    cache_store.write(key(value), translation)
    translation
  end

  def key(value)
    hash = Digest::MD5.hexdigest(value)
    "#{@source_language}:#{@target_language}:#{hash}"
  end

  def cache_store
    GoogleTranslateDiff.cache_store
  end
end

#read_multi
#EbayMag2.redis { |redis| redis.mget(*keys) }
#EbayMag2.redis { |redis| redis.setex(key(value), TIMEOUT, translation) }
