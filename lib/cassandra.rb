#!/usr/bin/env ruby
require 'cassandra'
require 'logger'
require 'json'
require 'bunny'
require 'digest/md5'
require 'connection_pool'

CASSANDRA_KEY= ENV['CASSANDRA_KEY']
CASSANDRA_CF = ENV['CASSANDRA_CF']
RMQ_INBOUND  = ENV['RMQ_INBOUND']

$cass = ConnectionPool::Wrapper.new(size: 5, timeout: 5) { 
  client = Cassandra.new(CASSANDRA_KEY, '127.0.0.1:9160')
}

$logger = Logger.new('/tmp/tweet-stream.log')

def bunny_client
  rmq = Bunny.new
  rmq.start

  ch   = rmq.create_channel
  qin  = ch.queue(RMQ_INBOUND)
  x    = ch.default_exchange

  {queue_in: qin, exchange: x, channel: ch}
end


def persist(payload)
  tweet = JSON.parse(payload)
  hash  = Digest::MD5.hexdigest(tweet['id_str'])[0]
  key   = "#{tweet['id_str']}:#{hash}"
  $logger.info "Persisting #{key}"
  $cass.insert(CASSANDRA_CF, key, {tweet['id_str'] => payload})
end


def execute
  rmq = bunny_client

  rmq[:queue_in].subscribe(:manual_ack => true, :block => true)  do |delivery_info, metadata, payload|
    
    persist(payload)

    rmq[:channel].acknowledge(delivery_info.delivery_tag, false)
  end
end

begin
  execute
rescue Exception => e
  $logger.error caller
  $logger.error e.inspect
  sleep 2
end