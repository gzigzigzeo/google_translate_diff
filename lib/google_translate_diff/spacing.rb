class GoogleTranslateDiff::Spacing
  class << self
    def restore(left, right)
      spaces(leading(left)) + right.strip + spaces(trailing(left))
    end

    private

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
end
