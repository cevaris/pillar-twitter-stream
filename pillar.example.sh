#!/usr/bin/env bash

# Simple stream config
TWITTER_CONSUMER_KEY= \
TWITTER_CONSUMER_SECRET= \
TWITTER_OAUTH_TOKEN= \
TWITTER_OAUTH_SECRET= \
RMQ_OUTBOUND=stream.twitter.default \
$(which ruby) /git/pillar-twitter-stream/lib/stream.rb