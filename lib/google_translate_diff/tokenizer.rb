class GoogleTranslateDiff::Tokenizer < ::Ox::Sax
  def initialize(source)
    @pos = nil
    @source = source
    @tokens = nil
    @context = []
    @sequence = []
    @indicies = []
  end

  def instruct(target)
    start_markup(target)
  end

  def end_instruct(target)
    end_markup(target)
  end

  def start_element(name)
    start_markup(name)
  end

  def end_element(name)
    end_markup(name)
  end

  def attr(name, value)
    unless @context.last == :span && name == :class && value == "notranslate"
      return
    end
    @sequence[-1] = :notranslate
  end

  def text(value)
    return if value == ""
    @sequence << (SKIP.include?(@context.last) ? :markup : :text)
    @indicies << @pos - 1
  end

  def tokens
    @tokens ||= token_sequences_joined.tap { |tokens| make_sentences_from_last_token(tokens) }
  end

  private

  def token_sequences_joined
    raw_tokens.each_with_object([]) do |token, tokens|
      if tokens.empty? # Initial state
        tokens << token
      elsif tokens.last[1] == token[1] # Join series of tokens of the same type into one
        tokens.last[0].concat(token[0])
      else # If token before :markup is :text we need to split it into sentences
        make_sentences_from_last_token(tokens)
        tokens << token
      end
    end
  end

  def make_sentences_from_last_token(tokens)
    return if tokens.empty?
    tokens.concat(sentences(tokens.pop[0])) if tokens.last[1] == :text
  end

  # rubocop: disable Metrics/MethodLength
  def sentences(value)
    return [] if value.strip.empty?

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
  # rubocop:enable Metrics/MethodLength

  def raw_tokens
    @raw_tokens ||= @indicies.map.with_index do |i, n|
      first = i
      last = (@indicies[n + 1] || 0) - 1
      value = fix_utf(@source.byteslice(first..last))
      type = @sequence[n]
      type = :text if type == :notranslate
      [value, type]
    end
  end

  def fix_utf(value)
    value.encode(
      "UTF-8", undef: :replace, invalid: :replace, replace: " "
    )
  end

  def nontranslate?(name)
    @sequence[-2] == :notranslate && name == :span
  end

  def start_markup(name)
    @context << name
    @sequence << :markup
    @indicies << @pos - 1
  end

  def end_markup(name)
    @context.pop
    @sequence << (nontranslate?(name) ? :notranslate : :markup)
    @indicies << @pos - 1 unless @pos == @source.bytesize
  end

  class << self
    def tokenize(value)
      return [] if value.nil?
      tokenizer = new(value).tap do |h|
        Ox.sax_parse(h, StringIO.new(value), HTML_OPTIONS)
      end
      tokenizer.tokens
    end
  end

  SKIP = %i[script style].freeze
  HTML_OPTIONS = { smart: true, skip: :skip_none }.freeze
end
