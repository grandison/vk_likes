require 'fileutils'

_cset :asset_env, "RAILS_GROUPS=assets"

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RAILS_ENV=#{rails_env} #{try_sudo} bundle exec #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} test -e #{unicorn_pid} && kill `cat #{unicorn_pid}`; true"
  end

  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} test -e #{unicorn_pid} && kill -s QUIT `cat #{unicorn_pid}`; true"
  end

  task :reload, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} test -e #{unicorn_pid} && kill -s HUP `cat #{unicorn_pid}`"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    deploy.web.disable
    stop
    start
    deploy.web.enable
  end

  task :customize, :roles => :app do
    configs = %w(database.yml omniauth.yml)
    configs.each do |config|
      run %Q(ln -sf #{shared_path}/config/#{config} #{latest_release}/config/#{config})
    end
    run %Q(ln -sf #{shared_path}/uploads #{latest_release}/public/uploads)
  end
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
    end
  end
end

after "deploy:restart", "delayed_job:restart"
after 'deploy:finalize_update', 'deploy:customize', "deploy:assets:precompile"