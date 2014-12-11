[![Build Status](https://travis-ci.org/thimios/photoshareserver.svg?branch=master)](https://travis-ci.org/thimios/photoshareserver)
[![Code Climate](https://codeclimate.com/github/thimios/photoshareserver/badges/gpa.svg)](https://codeclimate.com/github/thimios/photoshareserver)
[![Test Coverage](https://codeclimate.com/github/thimios/photoshareserver/badges/coverage.svg)](https://codeclimate.com/github/thimios/photoshareserver)

# PhotoShareServer

A rails application providing a REST-like API to develop a photo share application

It includes a clusterred solr search engine, a simple admin panel and a simple frontend

## Setup

Setup yml configuration files for all example files under config

Set a secret token at config/initializers/secret_token.rb. To generate a secret token, you can use:

	$ rake secret

run solr with logging on the console (you need it even for db setup)

	$ RAILS_ENV=development rake sunspot:solr:run

or start solr in the background:

	$ RAILS_ENV=development rake sunspot:solr:start 

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

Start solr:

	$ cap solr:start

Seed database:

	$ cap deploy:seed

Reindex solr on prod unfortunately does not work remotely, login, cd to current and run:

	$ RAILS_ENV=production rake sunspot:solr:reindex
	
View production logs:

	$ cap tail_logs 

Stop solr to release jvm resources:

	$ cap solr:stop




