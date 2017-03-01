require "google_translate_diff"
require "redis"
require "connection_pool"
require "redis-namespace"

GoogleTranslateDiff::RedisCacheStore.new("aaa")

ENV["TRANSLATE_KEY"] = "AIzaSyBSvs4SATOo3XDqCJTxKindbiVRmc-m800"

GoogleTranslateDiff.api = Google::Cloud::Translate.new
GoogleTranslateDiff.cache_store = GoogleTranslateDiff::RedisCacheStore.new(
  ConnectionPool.new(size: 2, timeout: 5) { Redis.connect }
)
puts GoogleTranslateDiff.translate("тест", "<b>фраза &eacute; &nbsp; &mdash; века</b>", from: "ru", to: "en").inspect
