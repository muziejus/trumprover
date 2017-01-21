# encoding: utf-8

require "sinatra/base"
require "nokogiri"
require "open-uri"
require "dotenv"
require "selenium-webdriver"

Dotenv.load

class App < Sinatra::Base

  use Rack::Session::Cookie,
    secret: ENV['COOKIE']

  get "/" do
    erb :index
  end

  post "/" do
    tweet_url = params[:input_url]
    unless tweet_url =~ /^https:\/\// # maybe confused by the "https://" in the hint.
      tweet_url = "https://" + tweet_url
    end
    tweet = Nokogiri::HTML(open(tweet_url)).css('div.permalink-tweet')
    if tweet.attribute('data-screen-name').text =~ /^(potus|realdonaldtrump)$/i
      tweet_text = tweet.css('p.TweetTextSize--26px').text
      erb :results, locals: { tweet_text: tweet_text }, layout: :naked
    else
      erb :not_trump_tweet, { layout: :naked }
    end
    

    # d = Selenium::WebDriver.for :firefox
    # d.navigate.to tweet_url
    # if d.find_element(class: "permalink-tweet") && d.find_element(class: "permalink-tweet").attribute("data-screen-name") =~ /^(potus|realdonaldtrump)$/i 
    #   tweet_text = d.find_element(class: "TweetTextSize--26px").text
    #   puts tweet_text
    # else
    #   puts "doesn't look like a trump tweet after all."
    # end
    # d.quit
  end

end
