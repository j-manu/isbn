$: << File.dirname(__FILE__)
require 'bundler'
Bundler.require(:default, :app)

require 'goliath'
require 'goliath/rack/templates'
require 'slim'
require 'store'

class ISBN < Goliath::API
  include Goliath::Rack::Templates
  use Goliath::Rack::Params
  use Goliath::Rack::Validation::RequiredParam, {key: 'isbn'}

  def response(env)
    Store.fetch_prices(env.config['redis'], params[:isbn])
    [200, {}, 'success']
  end
end

class Poll < Goliath::API
end

class WSEndPoint < Goliath::API
end

class Home < Goliath::API
  include Goliath::Rack::Templates

  def response(env)
    [200, {}, slim(:home, :views => Goliath::Application.root_path('views'))]
  end
end

class App < Goliath::API

  get '/', Home
  map '/price', ISBN
  map '/poll', Poll
end
