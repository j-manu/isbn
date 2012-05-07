require 'book'
require 'store'

class Fetcher
  @queue = :fetch

  def self.perform(isbn, store_name)
    store = Store::STORES[store_name.to_sym]
    url = store[:url].gsub('[isbn]',isbn.to_s)
    book = Book.new(isbn, Resque.redis)

    begin
      agent = ::Mechanize.new { |agent|
        agent.open_timeout   = 5
        agent.read_timeout   = 5
      }
      page = agent.get(url)
      price = Store.parse_price(page.search(store[:pattern]).text)
    rescue
      price = nil
    end
    book.cache_price(price, store_name, url)
  end
end
