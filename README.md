# PhotoShareServer

A rails application providing a REST-like API to develop a photo share application

It includes a clusterred solr search engine, a simple admin panel and a simple frontend

## Setup

Setup yml configuration files for all example files under config

start solr (you need it even for db setup)

	$ RAILS_ENV=development rake sunspot:solr:run

setup database:

	$ rake db:setup

seed database (take a look at db/seeds.rb first! public passwords will be seeded to the database!):

	$rake db:seed

Reindex solr:

	$ RAILS_ENV=development rake sunspot:solr:reindex

Start application (solr should be running already):

	$ rails s


## Deployment on uberspace:

edit config/deploy.rb

Setup environment: 

	$ bundle exec cap deploy:setup

Set a secret token for the production installation:

generate a token:

	$ rake secret

create  a shared/config/initializers/secret_token.rb file in the RAILS_ROOT on the production web server:

```ruby
# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
PhotoShareServer::Application.config.secret_token = '{secret token}'
```

Deploy:
	
	$ bundle exec cap deploy:migrations
	
View production logs:

	$ cap tail_logs 




