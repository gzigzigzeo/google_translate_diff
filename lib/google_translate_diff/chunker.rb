class GoogleTranslateDiff::Chunker
  extend ::Dry::Initializer

  class Error < StandardError; end

  Chunk = Struct.new(:values, :size)

  param :values
  option :limit, default: proc { MAX_CHUNK_SIZE }
  option :count_limit, default: proc { COUNT_LIMIT }

  def call
    chunks.map(&:values)
  end

  def chunks
    values.each_with_object([]) do |value, chunks|
      validate_value_size(value)

      tail = chunks.last

      if next_chunk?(tail, value)
        chunks << Chunk.new([], 0)
        tail = chunks.last
      end

      update_chunk(tail, value)
    end
  end

  private

  def next_chunk?(tail, value)
    tail.nil? ||
      (size(value) + tail.size > limit) ||
      tail.values.size > count_limit
  end

  def size(text)
    URI.encode(text).size
  end

  def update_chunk(chunk, value)
    chunk.values << value
    chunk.size = chunk.size + value.size
  end

  def validate_value_size(value)
    raise Error, "Too long part #{value.size} > #{limit}" if value.size > limit
  end

  MAX_CHUNK_SIZE = 1700
  COUNT_LIMIT = 120
end
