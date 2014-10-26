


# This capistrano deployment recipe is made to work with the optional
# StackScript provided to all Rails Rumble teams in their Linode dashboard.
#
# After setting up your Linode with the provided StackScript, configuring
# your Rails app to use your GitHub repository, and copying your deploy
# key from your server's ~/.ssh/github-deploy-key.pub to your GitHub
# repository's Admin / Deploy Keys section, you can configure your Rails
# app to use this deployment recipe by doing the following:
#
# run  ssh -T -oStrictHostKeyChecking=no git@bitbucket.org
# ssh-keygen -t rsa
# copy public key to bitbucket
# sudo apt-get install openjdk-7-jdk  git  imagemagick  nginx mysql-server libmysqlclient-dev
# copy config/deploy/ssl to /etc/nginx/ssl (only keys are needed, see config/deploy/nginx_conf.erb)
# sudo rm /etc/nginx/sites-enabled/default
# sudo apt-get remove apache2
# create mysql database for root user

# 1. Add `gem 'capistrano'` to your Gemfile.
# 2. Run `bundle install --binstubs --path=vendor/bundles`.
# 3. Run `bin/capify .` in your app's root directory.
# 4. Replace your new config/deploy.rb with this file's contents.
# 5. Configure the two parameters in the Configuration section below.
# 6. Run `git commit -a -m "Configured capistrano deployments."`.
# 7. Run `git push origin master`.
# 8. Run `bin/cap deploy:setup`.
# 9. Run `bin/cap deploy:migrations` or `bin/cap deploy`.

# bin/cap deploy:solr_start
# bin/cap deploy:seed
#
# Note: You may also need to add your local system's public key to
# your GitHub repository's Admin / Deploy Keys area.
#
# Note: When deploying, you'll be asked to enter your server's root
# password. To configure password-less deployments, see below.

#############################################
##                                         ##
##              Configuration              ##
##                                         ##
#############################################

GIT_REPOSITORY_URL = 'git@bitbucket.org:thimios/photoshareserver.git'

# Roles
server 'photoshareserver.wantedpixel.com', :app, :web, :db, :primary => true
#server 'app02.photoshareserver.wantedpixel.com', :app, :web
#server 'app03.photoshareserver.wantedpixel.com', :app, :web

#############################################
#############################################

# General Options

set :bundle_flags,               "--deployment"

set :application,                "photoshare"
set :normalize_asset_timestamps, false
set :rails_env,                  "production"

set :user,                       "ubuntu"
set :deploy_to,                  "/home/#{user}/app"
set :application_hostname,       "photoshare.wantedpixel.com"


# Password-less Deploys (Optional)
#
# 1. Locate your local public SSH key file. (Usually ~/.ssh/id_rsa.pub)
# 2. Execute the following locally: (You'll need your Linode server's root password.)
#
#    cat ~/.ssh/id_rsa.pub | ssh root@ALIAS "cat >> ~/.ssh/authorized_keys"
#
# 3. Uncomment the below ssh_options[:keys] line in this file.
#
ssh_options[:keys] = ["~/.ssh/id_rsa"]

set :use_sudo, false
set :sudo_user, "ubuntu"

default_run_options[:pty] = true

# SCM Options
set :scm,        :git
set :repository, GIT_REPOSITORY_URL
set :branch,     "master"

set :rvm_type, :user  # Copy the exact line. I really mean :user here
set :normalize_asset_timestamps, false  # Убирает сёр ошибок со старыми папками жаваскрипта и имаджов

set :rvm_ruby_string, 'ruby-1.9.3-p194@senchatouch2'
set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"


before 'deploy:restart', 'deploy:migrate'
# Install RVM
before 'deploy:setup',   'rvm:install_rvm'
# Install Ruby
before 'deploy:setup',   'rvm:install_ruby'
# Or create gemset
before 'deploy',         'rvm:create_gemset'
after  'deploy',         'deploy:cleanup'

after "deploy:setup", "nginx:setup"

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end

after "deploy", "rvm:trust_rvmrc"

namespace :deploy do
  task :setup_solr_data_dir do
    run "mkdir -p #{shared_path}/solr/data"
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

task :install_unicorn_init_script, :roles => :app do
  set :user, sudo_user
  run "#{sudo} cp #{latest_release}/config/deploy/unicorn /etc/init.d/unicorn.#{application}"
  run "#{sudo} chmod 755 /etc/init.d/unicorn.#{application}"
  run "#{sudo} update-rc.d unicorn.#{application} defaults"
end

task :install_solr_init_script, :roles => :app do
  set :user, sudo_user
  run "#{sudo} cp #{latest_release}/config/deploy/solr /etc/init.d/solr.#{application}"
  run "#{sudo} chmod 755 /etc/init.d/solr.#{application}"
  run "#{sudo} update-rc.d solr.#{application} defaults"
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
#after 'deploy:update_code',  'install_unicorn_init_script'
#after 'deploy:update_code',  'install_solr_init_script'
after 'unicorn:stop', 'solr:stop'
before 'inicorn:start', 'solr:start'

require "rvm/capistrano"
require "bundler/capistrano"
require "capistrano-unicorn"
require 'capistrano/nginx/tasks'
#require "capistrano-file_db"
load 'deploy/assets'
