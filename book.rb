class Book < Struct.new(:isbn, :redis)
  class << self
    def is_isbn?(text)
      /^[0-9]{9}[0-9xX]$/.match(text) || /^[0-9]{13}$/.match(text)
    end
  end

  def key
    "isbn:#{isbn}"
  end

  def cache_price(price, store_name)
    if price
      redis.zadd key+':prices', price, {store: store_name, price: price}.to_json
    else
      redis.sadd key+':unavailable', store_name
    end
  end

  def get_prices
    prices = '['
    prices += redis.zrange("resque:#{key}:prices", 0, -1).join(',')
    prices += redis.smembers("resque:#{key}:unavailable").join(',')
    prices += ']'
  end

end
