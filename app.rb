# encoding: utf-8

require "sinatra/base"
require "sinatra/flash"
require "dotenv"

Dotenv.load

class App < Sinatra::Base

  use Rack::Session::Cookie,
    secret: ENV['COOKIE']
  # if Sinatra::Base.development?
  #   set secret: "supersecret"
  #   # set :session_secret, "supersecret"
  # end

  register Sinatra::Flash

  get "/" do
    erb :index
  end

  post "/" do
    # puts "puts"
    # puts params[:inputUrl]
    erb :results, {layout: :naked}
  end

end
