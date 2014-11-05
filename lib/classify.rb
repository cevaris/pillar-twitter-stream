#!/usr/bin/env ruby

require 'logger'
require 'json'
require "bunny"
require "set"
require "unicode_utils/casefold"

$logger = Logger.new('/tmp/tweet-stream.log')

def bunny_client
  rmq = Bunny.new
  rmq.start

  ch   = rmq.create_channel
  qout = ch.queue(ENV['RMQ_OUTBOUND'])
  qin  = ch.queue(ENV['RMQ_INBOUND'])
  x    = ch.default_exchange

  {queue_out: qout, queue_in: qin, exchange: x, channel: ch}
end



def check_for_terms(terms, value)

  value = UnicodeUtils.casefold(value)

  results = Set.new
  terms.each do |item|
    keywords = item.split(' ')
    if keywords.length == 1
      term = keywords[0]
      term = UnicodeUtils.casefold(term)
      results << term if value.index(term)
    else
      match = 0
      keywords.each do |term|
        term = UnicodeUtils.casefold(term)
        match += 1 if value.index(term)
      end
      results << item if match == keywords.length
    end
  end
  results
end



def classify(tweet, terms)

  # checks for matches using the rules specified at
  # https://dev.twitter.com/docs/streaming-apis/parameters#track
  
  results = Set.new
  results = results | check_for_terms(terms, tweet['text'])
  tweet['entities']['user_mentions'].each do |user|
    results = results | check_for_terms(terms, user['screen_name'])
  end
  tweet['entities']['hashtags'].each do |tag|
    results = results | check_for_terms(terms, tag['text'])
  end
  tweet['entities']['urls'].each do |url|
    results = results | check_for_terms(terms, url['expanded_url'])
    results = results | check_for_terms(terms, url['display_url'])
  end
  if tweet['entities']['media']
    tweet['entities']['media'].each do |url|
      results = results | check_for_terms(terms, url['expanded_url'])
      results = results | check_for_terms(terms, url['display_url'])
    end
  end
  results
end



def execute
  rmq = bunny_client

  rmq[:queue_in].subscribe(:manual_ack => true, :block => true)  do |delivery_info, metadata, payload|
       
    msg = JSON.parse(payload)

    tweet = msg['tweet']
    terms = msg['terms']

    puts tweet , terms

    # results = classify(tweet, terms)

    # if tweet['retweeted_status']
    #   results = results | classify(tweet['retweeted_status'], terms)
    # end

    # puts "WARNING: Unclassified tweet!!!" if results.size == 0
    # results = ["__unknown__"] if results.size == 0

    # f.puts "Tweet received: #{tweet.to_json}"
    # f.puts "Tweet collected because of these keywords: #{results.to_a.inspect}"

    # msg = {}
    # msg['tweet'] = tweet
    # msg['keywords'] = results.to_a

    # puts msg.to_json

    # rmq[:exchange].publish(msg.to_json, :persistent => true, :routing_key => rmq[:queue_out].name)

    rmq[:channel].acknowledge(delivery_info.delivery_tag, false)
  end

  puts "done"

end



begin
  execute
rescue Exception => e
  $logger.error caller
  $logger.error e.inspect
  sleep 2
end