class Translator::Request
  extend Dry::Initializer::Mixin

  param :from
  param :to
  param :values
  param :options

  def call
    return values if from == to
    # check rate limit

  end

  private

  def data
    @data ||= GoogleTranslateDiff::Linearizer.linearize(values)
  end

  def chunks
    @chunks ||= GoogleTranslateDiff::Chunker.new(data).call
  end

  class Error < StandardError; end
  class RateLimitExceeded < Error; end

  RATELIMIT = 8000

  # Translate string values in some json-like structure
  def translate(struct)
    # Wrap single value to array
    return translate([struct]).first unless struct.respond_to? :each

    # Do nothing if source and target languages are the same
    return struct if source_language == target_language

    # Extract texts from structure and translate them
    texts = linearize(struct, [])
    translations = translate_texts(texts)

    # Replace texts in source structure with translations
    update(struct, translations)
  end

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

  def list_translations(values)
    return [] if values.empty?
    self.class.log values
    service
      .list_translations(values, target_language, source: source_language)
      .translations
      .map { |t| decode(t.translated_text) }
  end

  def decode(value)
    HTMLEntities.new.decode(value)
  end

  def cache
    Translator::Cache.new(source_language, target_language)
  end

  class Chunk
    attr_reader :size

    def initialize
      @texts = []
      @size = 0
    end

    def append(text, size)
      @texts << text
      @size += size
    end

    def to_a
      @texts
    end
  end

  MAX_CHUNK_SIZE = 1800

  # Group text into set of chunks with size less than 2k chars
  def group_texts(texts)
    texts.each_with_object [] do |text, chunks|
      text_size = URI.encode(text).size + 3 # Calculate encoded text size

      # Create new chunk if current has not enough space
      unless chunks.last && chunks.last.size + text_size < MAX_CHUNK_SIZE
        chunks << Chunk.new
      end

      chunks.last.append(text, text_size)
    end.map(&:to_a)
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

  # Extract array of string values from json-like structure
  def linearize(struct, acc)
    case struct
    when Hash then
      struct.each do |_k, v|
        linearize(v, acc)
      end
    when Array then struct.each { |v| linearize(v, acc) }
    when String, Number then acc << struct
    end

    acc
  end

  # Update json-like structure by replacing string values by their translations
  # from given queue
  def update(struct, q)
    case struct
    when Hash then
      struct.each_with_object({}) do |(k, v), h|
        h[k] = update(v, q)
      end
    when Array then struct.map { |v| update(v, q) }
    when String then q.shift
    else struct
    end
  end
end
