class Book < Struct.new(:isbn, :redis)

  class << self
    def is_isbn?(text)
      text = text.strip.gsub('-','').upcase if text
      if /^[0-9]{9}[0-9xX]$/.match(text)
        isbn_10_to_13(text)
      elsif /^[0-9]{13}$/.match(text)
        text
      else
        nil
      end
    end

    def isbn_10_to_13(isbn10)
      match = %r|^([0-9]{9})[0-9xX]$|.match(isbn10)
      return false if match.nil?

      substring = match[1]
      isbn10 = isbn10.chars.to_a

      sum_of_digits = 38 + 3 * (isbn10[0].to_i + isbn10[2].to_i + isbn10[4].to_i + isbn10[6].to_i + isbn10[8].to_i) +
                        isbn10[1].to_i + isbn10[3].to_i + isbn10[5].to_i + isbn10[7].to_i
      check_digit = (10 - (sum_of_digits % 10)) % 10

      %|978#{substring}#{check_digit}|
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
