require "ox"
require "punkt-segmenter"
require "dry/initializer"

require "google_translate_diff/version"
require "google_translate_diff/tokenizer"
require "google_translate_diff/linearizer"
require "google_translate_diff/chunker"

module GoogleTranslateDiff
  attr_accessor :api
  attr_accessor :cache

  def translate(*values, **options)
    options = options.dup
    from = options.delete(:from)
    to = options.delete(:to)

    raise ArgumentError, ":from and :to must be specified" unless from && to

    Request.new(from, to, values, options).call
  end
end
