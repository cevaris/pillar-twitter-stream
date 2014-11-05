#!/usr/bin/env ruby

require 'tweetstream'

TweetStream.configure do |config|
  config.consumer_key       = ENV
  config.consumer_secret    = '0123456789'
  config.oauth_token        = 'abcdefghijklmnopqrstuvwxyz'
  config.oauth_token_secret = '0123456789'
  config.auth_method        = :oauth
end