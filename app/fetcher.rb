require 'book'
require 'store'

class Fetcher
  include Sidekiq::Worker
  sidekiq_options queue: :fetch, timeout: 15

  def perform(isbn, store_name)
    store = Store::STORES[store_name.to_sym]
    url = store[:url].gsub('[isbn]',isbn.to_s)
    book = Book.new(isbn, Redis.new)

    begin
      agent = ::Mechanize.new { |agent|
        agent.open_timeout   = 5
        agent.read_timeout   = 5
        agent.follow_meta_refresh = true
      }
      page = agent.get(url)
      price = Store.parse_price(page.search(store[:pattern]).text)
    rescue
      price = nil
    end
    store_name = store[:name] || store_name.titleize
    book.cache_price(price, store_name, url)
  end
end
