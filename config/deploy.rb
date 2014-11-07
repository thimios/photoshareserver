# include uberspacify base recipes
require 'uberspacify/base'

# comment this if you don't use MySQL
require 'uberspacify/mysql'

# the Uberspace server you are on
server 'aries.uberspace.de', :web, :app, :db, :primary => true

# your Uberspace username
set :user, 'wantedsi'

# a name for your app, [a-z0-9] should be safe, will be used for your gemset,
# databases, directories, etc.
set :application, 'photoshareserver'

# SCM Options
set :scm,        :git
set :repository, 'git@github.com:thimios/photoshareserver.git'
set :branch,     "master"

# By default, your app will be available in the root of your Uberspace. If you
# have your own domain set up, you can configure it here
set :domain, 'demo1.wantedpixel.com'

# By default, Ruby Enterprise Edition 1.8.7 is used for Uberspace. If you
# prefer Ruby 1.9 or any other version, please refer to the RVM documentation
# at https://rvm.io/integration/capistrano/ and set this variable.
set :rvm_ruby_string, 'ruby-2.1@photoshare'

set :normalize_asset_timestamps, false

namespace :deploy do
  task :setup_solr_data_dir do
    run "mkdir -p #{shared_path}/solr/data"
  end

  task :symlink_secret_token, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/initializers/secret_token.rb #{release_path}/config/initializers/secret_token.rb" # This file is not included repository, so we will create a symlink 
  end

end

namespace :db do
  task :drop,:roles => :db do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:drop"
  end

  task :setup,:roles => :db do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:setup"
  end

  task :load_schema,:roles => :db do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:schema.load"
  end

  task :seed,:roles => :db do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:seed"
  end
end

namespace :solr do
  desc "start solr"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec sunspot-solr start --port=8983 --data-directory=#{shared_path}/solr/data --pid-dir=#{shared_path}/pids --solr-home=#{current_path}/solr  --log-file=#{shared_path}/log/sunspot-solr-production.log"
  end
  desc "stop solr"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec sunspot-solr stop --port=8983 --data-directory=#{shared_path}/solr/data --pid-dir=#{shared_path}/pids --solr-home=#{current_path}/solr --log-file=#{shared_path}/log/sunspot-solr-production.log"
  end

  desc "reindex the whole database"
  task :reindex, :roles => :app do
    stop
    # run "rm -rf #{shared_path}/solr/data"
    start

    input = ''
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:reindex[,,true]" do |channel, stream, data|
      next if data.chomp == input.chomp || data.chomp == ''
      print data
      channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
    end
  end
end

desc "tail production log files"
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

desc "remotely console"
task :console, :roles => :app do
  input = ''
  run "cd #{current_path} && ./script/console #{ENV['RAILS_ENV']}" do |channel, stream, data|
    next if data.chomp == input.chomp || data.chomp == ''
    print data
    channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
  end
end

after 'deploy:setup', 'deploy:setup_solr_data_dir'

load 'deploy/assets'
