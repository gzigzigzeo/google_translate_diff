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

  def sentences(value)
    sentences =
      Punkt::SentenceTokenizer
      .new(value)
      .sentences_from_text(value, output: :sentences_text)

    return [[value, :text]] if sentences.size == 1

    sentences.map.with_index do |s, index|
      [index == sentences.size - 1 ? s : "#{s} ", :text]
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
end
