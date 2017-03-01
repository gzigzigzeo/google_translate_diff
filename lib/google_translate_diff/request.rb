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

    puts "DATA: #{data.inspect}"
    puts "TOKENS: #{tokens.inspect}"
    puts "TEXT_TOKENS: #{text_tokens.inspect}"

    #puts "CHUNKS: #{chunks.inspect}"

    translation
  end

  private

  def data
    @data ||= GoogleTranslateDiff::Linearizer.linearize(values)
  end

  def tokens
    @tokens ||= data.each_with_object([]) do |value, tokens|
      tokens.concat(GoogleTranslateDiff::Tokenizer.tokenize(value))
    end
  end

  def text_tokens
    @text_tokens ||= extract_text_tokens.compact.to_h
  end

  def text_tokens_data
    @text_tokens_data ||= GoogleTranslateDiff::Linearizer.linearize(text_tokens)
  end

  def chunks
    @chunks ||= GoogleTranslateDiff::Chunker.new(text_tokens_data).call
  end

  def result
    @result ||= chunks.map do |chunk|
      cached, missing = cache.cached_and_missing(chunk)
      if missing.empty?
        chunk
      else
        cache.store(chunk, cached, call_api(missing))
      end
    end
  end

  def translation
    @translation ||=
      GoogleTranslateDiff::Linearizer.restore(values, result.flatten)
  end

  def extract_text_tokens
    tokens.map.with_index do |(value, type), index|
      [index.to_s, value] if type == :text
    end
  end

  def call_api(values)
    [GoogleTranslateDiff.api.translate(*values, **options)].flatten.map(&:text)
  end

  def cache
    @cache ||= GoogleTranslateDiff::Cache.new(from, to)
  end

  # -----

  class Error < StandardError; end
  class RateLimitExceeded < Error; end

  RATELIMIT = 8000

  private

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
