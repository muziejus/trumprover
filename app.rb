# encoding: utf-8

require "sinatra/base"
require "nokogiri"
require "open-uri"
require "dotenv"
require "selenium-webdriver"
require "RMagick"
require "headless"
require "./imgur"
require "./models"

Dotenv.load

class App < Sinatra::Base

  include Magick

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
    begin
      tweet = Nokogiri::HTML(open(tweet_url)).css('div.permalink-tweet')
      if tweet.attribute('data-screen-name').text =~ /^(potus|realdonaldtrump)$/i
        tweet_text = tweet.css('p.TweetTextSize--26px').text
        tweet_text = tweet_text[0..140]
        erb :results, locals: { tweet_url: tweet_url, tweet_text: tweet_text }, layout: :naked
      else
        erb :not_trump_tweet, { layout: :naked }
      end
    rescue
        erb :not_trump_tweet, { layout: :naked }
    end
  end

  post "/change-tweet" do
    new_tweet_text = params[:tweet_textarea][0..140].gsub(/^"/, "“").gsub(/ "/, " “").gsub(/"/, "”").gsub(/'/, "’").gsub(/(\r|\n)/, " ")
    new_image = "images/new_tweet_#{Time.now.to_i.to_s}.png" 
    if ENV['RACK_ENV'] == "production"
      headless = Headless.new
      headless.start
    end
    d = Selenium::WebDriver.for :firefox
    d.navigate.to params[:tweet_url]
    d.execute_script("document.getElementsByClassName('TweetTextSize--26px')[0].innerHTML='#{new_tweet_text}';")
    d.save_screenshot("public/#{new_image}")
    d.quit
    if ENV['RACK_ENV'] == "production"
      headless.destroy
    end
    image = ImageList.new("public/#{new_image}")
    main_img = image.crop(240, 50, 660, 1024)
    main_img.write("public/#{new_image}")
    thumb = image.crop(240, 50, 660, 330)
    thumb.write("public/#{new_image.gsub(/\.png$/, "_thumb.png")}")
    if ENV['RACK_ENV'] == "production"
      imgur_url = upload_image(new_image)
      imgur_url_thumb = upload_image("#{new_image.gsub(/\.png$/, "_thumb.png")}")
      unless imgur_url
        refresh_token
        imgur_url = upload_image(new_image)
      end
      unless imgur_url_thumb
        refresh_token
        imgur_url_thumb = upload_image("#{new_image.gsub(/\.png$/, "_thumb.png")}")
      end
    else
      imgur_url = "#{new_image}"
      imgur_url_thumb = "#{new_image.gsub(/\.png$/, "_thumb.png")}"
    end
    entry = Twimage.new
    entry.attributes = { text: new_tweet_text, original_tweet: params[:tweet_url], imgur_url: imgur_url, imgur_url_thumb: imgur_url_thumb, created_at: Time.now }
    begin
      entry.save
      redirect "/#{entry.id}"
    rescue DataMapper::SaveFailureError => e
      erb :error, locals: { e: e, validation: entry.errors.values.join(', ') }
    rescue StandardError => e
      erb :error, locals: { e: e }
    end
  end

  get "/:id" do
    entry = Twimage.get params[:id]
    erb :changed_tweet, locals: { imgur_url: entry.imgur_url, tweet_url: entry.original_tweet, image_url: entry.imgur_url, tweet_text: entry.text, imgur_url_thumb: entry.imgur_url_thumb }, layout: :single_tweet_layout
  end

end
