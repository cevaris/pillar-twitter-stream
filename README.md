rmq-twitter-stream
==================

Twitter streaming example via RabbitMQ.



## Prerequisites
- Cassandra
- RabbitMQ
- Twitter Credentials



## Getting Started

After installing Cassandra and RabbitMQ start the services.

	# Cassandra
	$ sudo cassandra
	
	# Install RabbitMQ web console and start server 
	$ rabbitmq-plugins enable rabbitmq_management
	$ rabbitmq-server
	
	
Insert Cassandra schema.

	cassandra-cli -f ./cass-schema.cql

Install gem environment.

	$ bundle install
	
Duplicate the file `pillar.example.sh`.

	$ cp pillar.example.sh pillar.sh
	$ sudo chmod +x pillar.sh
	
Sign up for Twitter credentials at apps.twitter.com. And add your credentials to this file....

	TWITTER_CONSUMER_KEY= \
	TWITTER_CONSUMER_SECRET= \
	TWITTER_OAUTH_TOKEN= \
	TWITTER_OAUTH_SECRET= \
	...
	
	
Finally, execute pillar.sh.

	$ ./pillar.sh

	

	

	
	