source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#jsonp middleware 

gem 'rack-cors', "~> 0.2.7", :require => 'rack/cors'

gem 'rack-jsonp-middleware', "~> 0.0.9",  :require => 'rack/jsonp'

# file uploads
gem "paperclip", "~> 3.4.1"

gem "paperclip-aws", "~> 1.6.7" #support for all locations without hacks

# solr searching
gem 'sunspot_rails', "~> 2.0.0"
gem 'sunspot_solr', "~> 2.0.0" # optional pre-packaged Solr distribution for use in development
gem 'progress_bar' # needed to show progress bar when indexing

# bundle exec rake sunspot:solr:start # or sunspot:solr:run to start in foreground
# bundle exec rake sunspot:solr:reindex

# Authentication
gem 'devise', "~> 2.1.2"

# Voting system
gem 'thumbs_up', '~> 0.6.4'

#geocoded locations for photos and users
gem 'geocoder', "~> 1.1.6"

#only used on html views to display gmaps
gem 'gmaps4rails', "~> 1.5.6"

# pagination
gem "kaminari", "~> 0.14.1"

gem 'faker'

# comments
gem 'opinio', "~> 0.6"

# activity feeds
gem 'public_activity', "~> 1.0.3"

gem 'bundler'

gem 'mysql2'

gem "acts_as_follower", "~> 0.1.1"

group :production do
  gem 'newrelic_rpm', "~> 3.5.8.72"
end

gem 'rack-ssl-enforcer', "~> 0.2.5"

gem 'unicorn'                 # Use unicorn as the app server

# To use Jbuilder templates for JSON
# gem 'jbuilder'

group :testing do
  gem 'test-unit'
end

# send email on exception in production
gem 'exception_notification'

group :development do
  gem 'capistrano'
  gem 'capistrano-unicorn'
  gem 'capistrano-nginx'
  gem 'rvm-capistrano'
  # gem 'linecache19'
  # gem 'ruby-debug19', :require => 'ruby-debug'
  # gem 'ruby-debug19', :require => false
  #gem 'ruby-debug-base19', :git => 'https://github.com/tribune/ruby-debug-base19.git', :require => false
  gem 'thin'
end

gem 'bullet'
gem 'xmpp4r'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'compass-rails'
  gem 'compass-h5bp'
  gem "therubyracer", :require => 'v8'
  gem 'libv8'

  gem 'jquery-datatables-rails'

  # only precompile updated assets
  gem 'turbo-sprockets-rails3'
end

gem 'jquery-rails'
gem 'html5-rails'

#authorization
gem "cancan", "~> 1.6.9"

# deployment on uberspace.de
gem 'uberspacify'