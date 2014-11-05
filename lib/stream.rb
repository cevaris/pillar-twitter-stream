#!/usr/bin/env ruby

require 'tweetstream'
require 'logger'
require 'json'
require 'thread'
require "bunny"

logger = Logger.new('/tmp/tweet-stream.log')


def queue
  rmq = Bunny.new
  rmq.start

  ch = rmq.create_channel
  q  = ch.queue(ENV['RMQ_OUTBOUND'], :auto_delete => true)
  x  = ch.default_exchange

  {queue: q, exchange: x}
end

def stream
  TweetStream.configure do |config|
    config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
    config.oauth_token        = ENV['TWITTER_OAUTH_TOKEN']
    config.oauth_token_secret = ENV['TWITTER_OAUTH_SECRET']
    config.auth_method        = :oauth
  end

  rmq = queue

  TweetStream::Client.new.on_reconnect do |timeout, retries|
    puts "#{timeout.inspect} #{retries.inspect}"
  end.on_error do |message|
    puts message.inspect
  end.sample do |status|
    rmq[:exchange].publish(JSON.generate(status.to_h), :routing_key => rmq[:queue].name)
  end
end

begin
  stream
rescue Exception => e
  puts caller
  puts e.inspect
  sleep 2
end

