CREATE KEYSPACE pillar_tweet_stream
    WITH placement_strategy = 'SimpleStrategy'
    AND strategy_options = {replication_factor:1};

USE pillar_tweet_stream;

CREATE COLUMN FAMILY tweets
    WITH comparator = UTF8Type
    AND key_validation_class=UTF8Type;