# encoding: utf-8

require "sinatra/base"
require "sinatra/flash"
require "dotenv"
require "selenium-webdriver"

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
    tweet_url = params[:input_url]
    unless tweet_url =~ /^https:\/\// # maybe confused by the "https://" in the hint.
      tweet_url = "https://" + tweet_url
    end
    d = Selenium::WebDriver.for :firefox
    d.navigate.to tweet_url
    if d.find_element(class: "permalink-tweet") && d.find_element(class: "permalink-tweet").attribute("data-screen-name") =~ /^(potus|realdonaldtrump)$/i 
      tweet_text = d.find_element(class: "TweetTextSize--26px").text
      puts tweet_text
    else
      puts "doesn't look like a trump tweet after all."
    end
    d.quit
    erb :results, {layout: :naked}
  end

end
