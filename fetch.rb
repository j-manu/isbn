require 'book'
require 'store'

class Fetch
  @queue = :fetch

  def self.perform(isbn, store_name)
    store = Store::STORES[store_name.to_sym]
    url = store[:url].gsub('[isbn]',isbn)

    agent = ::Mechanize.new { |agent|
      agent.open_timeout   = 5
      agent.read_timeout   = 5
    }
    page = agent.get(url)
    price = Store.parse_price(page.search(store[:pattern]).text)
    book = Book.new(isbn, Resque.redis)
    book.cache_price(price, store_name)
  end
end
