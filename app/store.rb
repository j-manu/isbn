require 'multi_json'
class Store
  INFO_STORES = { flipkart: { url: 'http://www.flipkart.com/search.php?query=[isbn]',
                              book_name: 'div.mprod-summary-title h1', author_name: 'div.mprod-summary-title .primary-info a',
                              image: '#visible-image-small' } }

  STORES = {flipkart: {
              url: 'http://www.flipkart.com/search.php?query=[isbn]',
              pattern: 'span#fk-mprod-our-id'},
            infibeam: {
              url: 'http://www.infibeam.com/Books/search?q=[isbn]',
              pattern: '#infiPrice'},
            crossword: {
              url: 'http://www.crossword.in/books/search?q=[isbn]',
              pattern: '.variant-final-price'},
            landmark: {
              url: 'http://www.landmarkonthenet.com/product/SearchPaging.aspx?code=[isbn]&type=0&num=0',
              pattern: '.pricebox .price-current .WebRupee-print'},
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
