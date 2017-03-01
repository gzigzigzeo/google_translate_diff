require "ox"
require "punkt-segmenter"
require "dry/initializer"
require "google/cloud/translate"

require "google_translate_diff/version"
require "google_translate_diff/tokenizer"
require "google_translate_diff/linearizer"
require "google_translate_diff/chunker"
require "google_translate_diff/cache"
require "google_translate_diff/redis_cache_store"
require "google_translate_diff/redis_rate_limiter"
require "google_translate_diff/request"

module GoogleTranslateDiff
  class << self
    attr_accessor :api
    attr_accessor :cache_store
    attr_accessor :rate_limiter

    def translate(*values, **options)
      options = options.dup
      from = options.fetch(:from)
      to = options.fetch(:to)

      raise ArgumentError, ":from and :to must be specified" unless from && to

      Request.new(from, to, values, options).call
    end
  end
end
