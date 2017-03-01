class GoogleTranslateTricks::Tokenizer < ::Ox::Sax
  def initialize(source)
    @pos = nil
    @prev = 1
    @skip = false
    @source = source
    @tokens = []
  end

  attr_reader :texts, :tokens, :prev, :pos

  def start_element(name)
    @skip = true if name == :script
  end

  def end_element(name)
    @skip = false if name == :script
  end

  def text(value)
    return if @skip
    value = fix_utf(value)
    return if value.strip.empty?

    token.tap { |t| @tokens << [fix_utf(t), :markup] if t }
    @tokens.concat(sentences(value))

    @prev = @pos + value.bytesize
  end

  def token
    return if @prev == @pos
    fix_utf(@source.byteslice((@prev - 1)..(@pos - 2)))
  end

  # Splits text by sentences
  def sentences(value)
    boundaries =
      Punkt::SentenceTokenizer
      .new(value)
      .sentences_from_text(value)

    return [[value, :text]] if boundaries.size == 1

    boundaries.map.with_index do |(left, right), index|
      next_boundary = boundaries[index + 1]
      right = next_boundary[0] - 1 if next_boundary

      [value[left..right], :text]
    end
  end

  def cut_last_token
    last_token = fix_utf(@source.byteslice((@prev - 1)..-1))
    @tokens << [last_token, :markup] if last_token != ""
  end

  def fix_utf(value)
    value.encode(
      "UTF-8", undef: :replace, invalid: :replace, replace: " "
    )
  end

  CHUNK_SIZE = 2000
end

=begin
def chunks(tokens)
  # URI.encode(text).size + 3
  tokens.each_with_object([]) do |token, result|
    value = token.first
    if value.length <= CHUNK_SIZE
      result << token
    else
      value.split("").each_slice(CHUNK_SIZE).map do |chunk|
        result << [chunk.join, :text]
      end
    end
  end
end
=end
