source 'https://rubygems.org'

gem 'rails', '3.2.3'


# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

  gem 'sqlite3'
# gem 'pg'

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

#jsonp middleware 

gem 'rack-cors', :require => 'rack/cors'
  

gem 'rack-jsonp-middleware',  :require => 'rack/jsonp'

# file uploads
gem "paperclip", "~> 3.0"

# s3 storage for paperclip
gem 'aws-sdk', '~> 1.3.4'

# solr searching
gem 'sunspot_rails', "~> 2.0.0.pre"
gem 'sunspot_solr', "~> 2.0.0.pre" # optional pre-packaged Solr distribution for use in development
gem 'progress_bar' # needed to show progress bar when indexing

# bundle exec rake sunspot:solr:start # or sunspot:solr:run to start in foreground
# bundle exec rake sunspot:solr:reindex

# Authentication
gem 'devise', "2.1.2"

# Voting system
gem 'thumbs_up'

#geocoded locations for photos and users
gem 'geocoder'

#only used on html views to display gmaps
gem 'gmaps4rails'

# pagination
gem "kaminari" ,'0.14.1'

gem 'faker'

# comments
gem 'opinio', '0.6'

# activity feeds
gem 'public_activity', '0.5.0'

gem 'bundler'

gem 'mysql2'

gem "acts_as_follower"

group :production do
  gem 'newrelic_rpm'
end

gem 'rack-ssl-enforcer'

gem 'unicorn'                 # Use unicorn as the app server

# To use Jbuilder templates for JSON
# gem 'jbuilder'

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

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'compass-rails'
  gem 'compass-h5bp'
  gem "therubyracer", :require => 'v8'
  gem 'libv8', '~> 3.11.8'
end


gem 'jquery-rails'
gem 'html5-rails'




