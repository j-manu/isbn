require 'multi_json'
class Store
  INFO_STORES = { flipkart: { url: 'http://www.flipkart.com/search.php?query=[isbn]', book_name: 'div.mprod-summary-title h1', author_name: 'div.mprod-summary-title h2', image_url: '#mprodimg-id img' } }

  STORES = {flipkart: {
              url: 'http://www.flipkart.com/search.php?query=[isbn]',
              pattern: 'span#fk-mprod-our-id'},
            infibeam: {
              url: 'http://www.infibeam.com/Books/search?q=[isbn]',
              pattern: '#infiPrice'},
            indiaplaza: {
              url: 'http://www.indiaplaza.com/searchproducts.aspx?sn=books&q=[isbn]',
              pattern: 'div.ourPrice'},
            crossword: {
              url: 'http://www.crossword.in/books/search?q=[isbn]',
              pattern: '.variant-final-price'},
            rediff: {
              url: 'http://books.rediff.com/book/ISBN:[isbn]',
              pattern: 'font#book-pric b'},
            indiaplaza: {
              url: 'http://www.indiaplaza.com/searchproducts.aspx?sn=books&q=[isbn]',
              pattern: 'div.ourPrice'},
            landmark: {
              url: 'http://www.landmarkonthenet.com/product/SearchPaging.aspx?code=[isbn]&type=0&num=0',
              pattern: '.price .current-price'},
            homeshop18: {
              url: 'http://www.homeshop18.com/search:[isbn]/',
              pattern: '.pdp_details_price .pdp_details_hs18Price'}
           }

  class << self
    def parse_price(text)
      return nil if text == ''
      text.strip!
      price = /[,\d]+(\.\d+)?$/.match(text).to_s.gsub(",","").to_f
      price > 0 ? price : nil
    end

    def num_stores
      STORES.size
    end
  end
end
