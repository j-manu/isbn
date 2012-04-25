$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__),  'app')
require 'bundler'
Bundler.require(:default, :app)

require 'goliath/rack/templates'
require 'store'
require 'book'

class ISBN < Goliath::API
  include Goliath::Rack::Templates
  use Goliath::Rack::Params
  use Goliath::Rack::Validation::RequiredParam, {key: :isbn}

  def response(env)
    Store.fetch_prices(env.config['redis'], params[:isbn])
    [200, {}, slim(:isbn, views: Goliath::Application.root_path('views'),
                   locals: {isbn: params[:isbn], num_stores: Store.num_stores })]
  end
end

class Poll < Goliath::API
  use Goliath::Rack::DefaultMimeType
  use Goliath::Rack::Render, 'json'
  use Goliath::Rack::Params

  def process_request
    i = 0
    while i < 50
      prices = Book.new(env.params[:isbn], env.config['redis']).prices(env.params[:stores].to_i)
      break if prices[:status] != 'fetching'
      i += 1
      EM::Synchrony.sleep(1)
    end
    prices
  end

  def response(env)
    [200, {}, process_request]
  end
end

class Home < Goliath::API
  include Goliath::Rack::Templates

  def response(env)
    [200, {}, slim(:home, :views => Goliath::Application.root_path('views'))]
  end
end

class App < Goliath::API
  include Goliath::Rack::Templates

  use(Rack::Static,
      :root => Goliath::Application.app_path("public"),
      :urls => ["/favicon.ico", '/stylesheets', '/javascripts', '/images'])

  get '/', Home
  map '/isbn/:isbn/price/', ISBN
  map '/poll', Poll
end
