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

  %w(info status num_stores).each do |attr|
    define_method attr do
      redis.hget key, attr
    end

    define_method "#{attr}=" do |val|
      redis.hset key, attr, val
    end
  end

  def cache_price(price, store_name, url)
    redis.sadd prices_key, {store: store_name, url: url, price: price.presence}.to_json
    if num_prices == Store.num_stores
      self.status = 'complete'
      # cache for 1 day
      redis.expire prices_key, 86400
    end
  end

  def cache_info(book_info)
    self.info = book_info.to_json
  end

  def num_prices
    redis.scard(prices_key)
  end

  def prices(current_stores=0)
    book_info = MultiJson.load(info) if info
    prices = redis.smembers(prices_key)
    # hack. if the price is nil, give sort a large number so it ranks in the bottom.
    prices = prices.map {|p| MultiJson.load p}.sort_by {|v| v['price'] || 999999999999}
    fetched_stores = prices.size
    status = fetched_stores == Store.num_stores ? 'complete' : (fetched_stores == current_stores ? 'fetching' : 'progress')
    {status: status, prices: prices, info: book_info }
  end

  def delete_prices
    redis.del(prices_key)
  end

  def fetch_prices
    # storing num_stores per book so that if more stores are added
    # prices are fetched again
    return if (status == 'complete' && num_stores.to_i == Store.num_stores &&
                num_prices == Store.num_stores) || status == 'fetching'

    self.status = 'fetching'
    self.num_stores = Store.num_stores

    delete_prices

    # we have to manually insert into queue instead of using Sidekiq
    # because Sidekiq won't be able to deal with async redis being used
    # by goliath
    %w(fetch info).each do |q_name|
      redis.sadd 'isbn:queues', q_name
    end
    Store::STORES.keys.each do |store_name|
      redis.rpush('isbn:queue:fetch', {class: 'Fetcher', args: [isbn.to_s, store_name.to_s]}.to_json)
    end

    unless info
      redis.rpush('isbn:queue:info', {class: 'InfoFetcher', args: [isbn.to_s]}.to_json)
    end
  end

  private

  def key
    redis.respond_to?(:namespace) ? isbn : "isbn:#{isbn}"
  end

  def prices_key
    key + ':prices'
  end
end
