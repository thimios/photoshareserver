


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
# copy public key to bitbucket
# apt-get install openjdk-7-jdk
# apt-get install imagemagick
# apt-get install nginx
#  apt-get remove apache2

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

GIT_REPOSITORY_URL = 'git@bitbucket.org:thimios/engineyardhipster.git'
LINODE_SERVER_HOSTNAME = '176.58.126.160'

#############################################
#############################################

# General Options

set :bundle_flags,               "--deployment"

set :application,                "soberlin"
set :normalize_asset_timestamps, false
set :rails_env,                  "production"

set :user,                       "deploy"
set :deploy_to,                  "/home/#{user}/app"
set :server_name,                LINODE_SERVER_HOSTNAME

# Password-less Deploys (Optional)
#
# 1. Locate your local public SSH key file. (Usually ~/.ssh/id_rsa.pub)
# 2. Execute the following locally: (You'll need your Linode server's root password.)
#
#    cat ~/.ssh/id_rsa.pub | ssh root@LINODE_SERVER_HOSTNAME "cat >> ~/.ssh/authorized_keys"
#
# 3. Uncomment the below ssh_options[:keys] line in this file.
#
# ssh_options[:keys] = ["~/.ssh/id_rsa"]

set :use_sudo, true
set :sudo_user, "deploy"

default_run_options[:pty] = true

# SCM Options
set :scm,        :git
set :repository, GIT_REPOSITORY_URL
set :branch,     "master"

set :rvm_type, :user  # Copy the exact line. I really mean :user here
set :normalize_asset_timestamps, false  # Убирает сёр ошибок со старыми папками жаваскрипта и имаджов

set :rvm_ruby_string, 'ruby-1.9.3-p194@soberlin'
set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"


# Roles

server LINODE_SERVER_HOSTNAME, :app, :web, :db, :primary => true

before 'deploy:restart', 'deploy:migrate'
# Install RVM
before 'deploy:setup',   'rvm:install_rvm'
# Install Ruby
before 'deploy:setup',   'rvm:install_ruby'
# Or create gemset
before 'deploy',         'rvm:create_gemset'
after  'deploy',         'deploy:cleanup'

after "deploy:setup", "nginx:setup", "nginx:reload"

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

namespace :solr do
  desc "start solr"
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec sunspot-solr start --port=8983 --data-directory=#{shared_path}/solr/data --pid-dir=#{shared_path}/pids  --log-file=#{shared_path}/log/sunspot-solr-production.log"
  end
  desc "stop solr"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec sunspot-solr stop --port=8983 --data-directory=#{shared_path}/solr/data --pid-dir=#{shared_path}/pids"
  end
  desc "reindex the whole database"
  task :reindex, :roles => :app do
    stop
    run "rm -rf #{shared_path}/solr/data"
    start
    run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake sunspot:solr:reindex"
  end
end

after 'deploy:setup', 'deploy:setup_solr_data_dir'

require "rvm/capistrano"
require "bundler/capistrano"
require "capistrano-unicorn"
require 'capistrano/nginx/tasks'
#require "capistrano-file_db"
load 'deploy/assets'