class GoogleTranslateDiff::Linearizer
  class << self
    def linearize(struct, array = [])
      case struct
      when Hash then
        struct.each { |_k, v| linearize(v, array) }
      when Array then
        struct.each { |v|     linearize(v, array) }
      else
        array << struct
      end

      array
    end

    def restore(struct, array)
      case struct
      when Hash then
        struct.each_with_object({}) { |(k, v), h| h[k] = restore(v, array) }
      when Array then
        struct.map { |v| restore(v, array) }
      else
        array.shift
      end
    end
  end
end
