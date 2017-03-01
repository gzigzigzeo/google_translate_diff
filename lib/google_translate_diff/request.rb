class GoogleTranslateDiff::Request
  extend Dry::Initializer::Mixin

  param :from
  param :to
  param :values
  param :options

  def call
    unless GoogleTranslateDiff.api
      raise "Assign GoogleTranslateDiff.api before calling ::translate"
    end

    unless GoogleTranslateDiff.cache_store
      raise "Assign GoogleTranslateDiff.cache_store before calling ::translate"
    end

    return values if from == to || values.empty?

    translation
  end

  private

  def data
    @data ||= GoogleTranslateDiff::Linearizer.linearize(values)
  end

  def translation
    @translation ||=
      GoogleTranslateDiff::Linearizer.restore(values, result.flatten)
  end

  def chunks
    @chunks ||= GoogleTranslateDiff::Chunker.new(data).call
  end

  def result
    @result ||= chunks.map do |chunk|
      cached, missing = cache.cached_and_missing(chunk)
      missing =
        GoogleTranslateDiff.api.translate(*missing, **options).map(&:text)
      cache.store(chunk, cached, missing)
    end
  end

  def cache
    @cache ||= GoogleTranslateDiff::Cache.new(from, to)
  end

  # -----

  class Error < StandardError; end
  class RateLimitExceeded < Error; end

  RATELIMIT = 8000

  private

  def translate_texts(texts)
    return texts if texts.blank?

    group_texts(texts).each_with_object [] do |source, results|
      pattern, missing = cache.hit(source)

      check_rate_limit(missing)

      translated = list_translations(missing)
      value = cache.store(source, pattern, translated)
      results.concat(value)
    end
  end

  def check_rate_limit(texts)
    size = texts.map(&:size).sum

    raise RateLimitExceeded if rate_limit.count + size >= RATELIMIT

    rate_limit.add size
  end

  def rate_limit
    @rate_limit ||= Redis::Ratelimit.new(
      "translator", interval: 100, bucket_count: 10, bucket_size: 15
    )
  end
end
