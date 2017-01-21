# encoding: utf-8

require "sinatra/base"
require "sinatra/flash"
require "dotenv"

class App < Sinatra::Base

  use Rack::Session::Cookie,
    secret: ENV['COOKIE']
  if Sinatra::Base.development?
    set :session_secret, "supersecret"
  end

  register Sinatra::Flash

  get "/" do
    erb :index
  end

end
