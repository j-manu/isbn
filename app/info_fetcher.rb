class InfoFetcher
  include Sidekiq::Worker
  sidekiq_options queue: :info, timeout: 15

  def perform(isbn)
    store = Store::INFO_STORES[:flipkart]
    url = store[:url].gsub('[isbn]',isbn.to_s)
    info = {}

    begin
      agent = ::Mechanize.new { |agent|
        agent.open_timeout   = 5
        agent.read_timeout   = 5
        agent.follow_meta_refresh = true
      }
      page = agent.get(url)

      info[:book_name] = page.search(store[:book_name]).text.strip
      info[:author_name] = page.search(store[:author_name]).text.strip
      info[:image_url] = page.search(store[:image_url]).first.attributes['src'].text
    rescue
    end
    Book.new(isbn, Redis.new).cache_info(info)
  end
end
