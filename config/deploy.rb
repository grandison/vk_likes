set :stages, %w(production)

require 'bundler/capistrano'
require 'capistrano/maintenance'
require 'capistrano/ext/multistage'
require 'delayed/recipes'

set :whenever_environment, defer { rails_env }
set :whenever_identifier, defer { "#{application}_#{rails_env}" }
set :whenever_command, 'bundle exec whenever'
require 'whenever/capistrano'

namespace :delayed_job do
  desc "Restart the delayed_job process"
  task :restart, :roles => :app do
    stop
    # wait_for_process_to_end('delayed_job')
    start
  end
end

def wait_for_process_to_end(process_name)
  run "COUNT=1; until [ $COUNT -eq 0 ]; do COUNT=`ps -ef | grep -v 'ps -ef' | grep -v 'grep' | grep -i '#{process_name}'|wc -l` ; echo 'waiting for #{process_name} to end' ; sleep 2 ; done"
end

set :delayed_job_args, "-n 2"