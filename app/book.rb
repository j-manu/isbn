class Book < Struct.new(:isbn, :redis)

  class << self
    def is_isbn?(text)
      /^[0-9]{9}[0-9xX]$/.match(text) || /^[0-9]{13}$/.match(text)
    end
  end

  def key
    redis.respond_to?(:namespace) ? isbn : "isbn:#{isbn}"
  end

  def prices_key
    key + ':prices'
  end

  def cache_price(price, store_name, url)
    redis.sadd prices_key, {store: store_name, url: url, price: price ? price : nil}.to_json
  end

  def prices(current_stores=0)
    prices = redis.smembers(prices_key)
    prices = prices.map {|p| MultiJson.load p}.sort_by {|v| v['price']}
    num_stores = prices.size
    status = num_stores == Store.num_stores ? 'complete' : (num_stores == current_stores ? 'fetching' : 'progress')
    {status: status, prices: prices}
  end

  def delete_prices
    redis.del(prices_key)
  end

end
