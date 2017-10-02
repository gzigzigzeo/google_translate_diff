# Adds same count leading-trailing spaces left has to the right
class GoogleTranslateDiff::Spacing
  class << self
    # GoogleTranslateDiff::Spacing.restore("  a ", "Z") # => "   Z "
    def restore(left, right)
      leading(left) + right.strip + trailing(left)
    end

    private

    def spaces(count)
      ([" "] * count).join
    end

    def leading(value)
      pos = value =~ /\A[^[:space:]]+/ui
      return "" if pos.nil? || pos.zero?
      value[0..(pos - 1)]
    end

    def trailing(value)
      pos = value =~ /[[:space:]]+\z/ui
      return "" if pos.nil?
      value[pos..-1]
    end
  end
end
