require 'fileutils'

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
    #run "sudo monit unmonitor vemmabode_unicorn unicorn_worker_1 unicorn_worker_2 unicorn_worker_3 unicorn_worker_4"
    deploy.web.disable
    stop
    start
    deploy.web.enable
    run "sudo monit -g background restart"
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
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
end

after "deploy:restart", "delayed_job:restart"
after 'deploy:finalize_update', 'deploy:customize'