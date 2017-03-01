class GoogleTranslateDiff::Spacing
  extend Dry::Initializer::Mixin

  param :left
  param :right

  def call
    right.map.with_index do |value, index|
      source = left[index]
      spaces(leading(source)) + value + spaces(trailing(source))
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
end
