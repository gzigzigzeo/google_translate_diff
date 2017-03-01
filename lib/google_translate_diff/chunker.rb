class GoogleTranslateDiff::Chunker
  extend ::Dry::Initializer::Mixin

  class Error < StandardError; end

  Chunk = Struct.new(:values, :size)

  param :values
  option :limit, default: proc { MAX_CHUNK_SIZE }

  def call
    chunks.map(&:values)
  end

  def chunks
    values.each_with_object([]) do |value, chunks|
      validate_value_size(value)

      tail = chunks.last

      if tail.nil? || (size(value) + tail.size > limit)
        chunks << Chunk.new([], 0)
        tail = chunks.last
      end

      update_chunk(tail, value)
    end
  end

  private

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

  MAX_CHUNK_SIZE = 1800
end
