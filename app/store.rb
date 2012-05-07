require 'multi_json'
class Store
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
              pattern: '.variant-final-price'}
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
