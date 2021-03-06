#!/usr/bin/env ruby

require 'logger'
require 'json'
require 'bunny'

$logger = Logger.new('/tmp/tweet-stream.log')
TERMS   = ENV['FILTER_TERMS'].split(':')

def bunny_client
  rmq = Bunny.new
  rmq.start

  ch   = rmq.create_channel
  qout = ch.queue(ENV['RMQ_OUTBOUND'])
  qin  = ch.queue(ENV['RMQ_INBOUND'])
  x    = ch.default_exchange

  {queue_out: qout, queue_in: qin, exchange: x, channel: ch}
end


def filter(payload)
  TERMS.select {|t| payload.match /#{t}/i }.empty? ? nil : payload
end


def execute
  rmq = bunny_client

  rmq[:queue_in].subscribe(:manual_ack => true, :block => true)  do |delivery_info, metadata, payload|
       
    filtered = filter(payload)

    if filtered
      rmq[:exchange].publish(filtered, :persistent => true, :routing_key => rmq[:queue_out].name)
    end

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