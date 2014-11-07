#!/usr/bin/env bash

# Simple stream config
TWITTER_CONSUMER_KEY= \
TWITTER_CONSUMER_SECRET= \
TWITTER_OAUTH_TOKEN= \
TWITTER_OAUTH_SECRET= \
FILTER_TERMS=gop:president:guns \
RMQ_OUTBOUND=stream.twitter.default \
$(which ruby) /git/pillar-twitter-stream/lib/stream.rb


# Simple filter config
FILTER_TERMS=gop:president \
RMQ_INBOUND=stream.twitter.default \
RMQ_OUTBOUND="stream.twitter.filter.$FILTER_TERMS" \
$(which ruby) /git/pillar-twitter-stream/lib/filter.rb

FILTER_TERMS=guns \
RMQ_INBOUND=stream.twitter.default \
RMQ_OUTBOUND="stream.twitter.filter.guns" \
$(which ruby) /git/pillar-twitter-stream/lib/filter.rb


# Sample cassandra persistence config 
FILTER_TERMS=gop:president \
RMQ_INBOUND="stream.twitter.filter.$FILTER_TERMS" \
CASSANDRA_KEY=pillar_tweet_stream \
CASSANDRA_CF=tweets \
$(which ruby) /git/pillar-twitter-stream/lib/cassandra.rb


