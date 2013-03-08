rails_env = ENV['RAILS_ENV'] || 'production'
worker_processes 1

base_dir = '/var/www/rails/10likes'

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

timeout 30
listen "#{base_dir}/shared/tmp/10likes.socket"
pid "#{base_dir}/shared/pids/unicorn.pid"
stderr_path "#{base_dir}/shared/log/unicorn.stderr.log"
stdout_path "#{base_dir}/shared/log/unicorn.stdout.log"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection

  port = 1 + worker.nr
  child_pid = server.config[:pid].sub('.pid', ".#{port}.pid")
  system("echo #{Process.pid} > #{child_pid}")
end