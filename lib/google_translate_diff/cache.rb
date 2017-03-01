class GoogleTranslateDiff::Cache
  extend Dry::Initializer::Mixin

  param :source_language
  param :target_language

  def hit(values)
    keys = values.map { |v| key(v) }
    pattern = EbayMag2.redis { |redis| redis.mget(*keys) }
    missing = values.map.with_index { |v, i| v if pattern[i].nil? }.compact

    [pattern, missing]
  end

  def store(source, pattern, translated)
    pattern.map.with_index do |value, index|
      value || store_value(source[index], translated.shift)
    end
  end

  def store_value(value, translation)
    EbayMag2.redis { |redis| redis.setex(key(value), TIMEOUT, translation) }
    translation
  end

  def key(value)
    hash = Digest::MD5.hexdigest(value)
    "translate:#{@source_language}:#{@target_language}:#{hash}"
  end
end
