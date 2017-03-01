class Translator::Markup
  extend Dry::Initializer::Mixin

  param :source_language
  param :target_language

  def translate(value)
    return value if value.blank?
    tokens = tokenize(value)
    values = extract_values(tokens)
    translated_values = translator.translate(values)
    translated_values = restore_spacing(translated_values, values)
    fix_ascii(update(tokens, translated_values)).strip
  end

  private

  def translator
    @translator ||= Translator::Request.new(source_language, target_language)
  end

  def tokenize(value)
    tokenizer = Translator::Tokenizer.new(value).tap do |h|
      Ox.sax_parse(h, StringIO.new(value))
      h.cut_last_token
    end
    tokenizer.tokens
  end

  def extract_values(tokens)
    h = tokens.map.with_index do |(v, t), index|
      [index.to_s, v] if t == :text
    end
    Hash[*h.compact.flatten]
  end

  def update(tokens, values)
    values.each { |index, value| tokens[index.to_i] = [value, :text] }
    tokens.map(&:first).join
  end

  def restore_spacing(translated_values, values)
    translated_values.map do |index, value|
      source = values[index]
      [index, spaces(leading(source)) + value + spaces(trailing(source))]
    end
  end

  def spaces(count)
    ([" "] * count).join
  end

  def leading(value)
    value.size - value.gsub(/^[[:space:]]+/ui, "").size
  end

  def trailing(value)
    value.size - value.gsub(/[[:space:]]+$/ui, "").size
  end

  # Assume that markup can not have \n\t and so on in unexpected places
  def fix_ascii(value)
    value.gsub(/[\u0000-\u001F]/, " ")
  end
end
