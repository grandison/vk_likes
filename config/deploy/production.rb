set :application, "vk_likes"
set :rails_env, "production"

server "10likes.ru", :app, :web, :db, :primary => true

set :user, "10likes"
set :domain, "10likes.ru"
set :repository, "git@github.com:grandison/vk_likes.git"
set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache
set :deploy_to, "/var/www/rails/10likes"
set :use_sudo, false

set :unicorn_binary, "/usr/local/bin/unicorn_rails"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"

set :normalize_asset_timestamps, false

load(File.dirname(__FILE__)  + '/common_tasks')

set :keep_releases, 10

after 'deploy', 'deploy:cleanup'