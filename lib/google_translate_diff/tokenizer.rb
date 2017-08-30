class GoogleTranslateDiff::Tokenizer < ::Ox::Sax
  def initialize(source)
    @pos = nil
    @prev = 1
    @skip = false
    @source = source
    @tokens = []
  end

  attr_reader :texts, :tokens, :prev, :pos

  def start_element(name)
    @skip = true if SKIP.include?(name)
  end

  def end_element(name)
    @skip = false if SKIP.include?(name)
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

  class << self
    def tokenize(value)
      return [] if value.nil?
      tokenizer = new(value).tap do |h|
        Ox.sax_parse(h, StringIO.new(value), HTML_OPTIONS)
        h.cut_last_token
      end
      tokenizer.tokens
    end
  end

  SKIP = %i[script style].freeze
  HTML_OPTIONS = { smart: true, skip: :skip_return }.freeze
end
