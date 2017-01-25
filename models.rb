require 'data_mapper'

# DATABASE_URL is set in Heroku by running: heroku config:set DATABASE_URL="postgres://glbtgtaptiiysf:_QlawKrTbN9xodoFfr_Ob0F3iH@ec2-54-204-12-25.compute-1.amazonaws.com:5432/dcshmudba3dko2"

DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/tweets.sqlite")

class Twimage
  include DataMapper::Resource
  property :id, Serial
  property :text, Text
  property :original_tweet, Text
  property :imgur_url, String
  property :imgur_url_thumb, String
  property :created_at, DateTime
end

DataMapper.finalize.auto_upgrade!  
Twimage.raise_on_save_failure = true

