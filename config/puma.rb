# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum, this matches the default thread size of Active Record.
#
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 1 }.to_i
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
#
port        ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
preload_app!

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted this block will be run, if you are using `preload_app!`
# option you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, Ruby
# cannot share connections between processes.
#
# on_worker_boot do
#   ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
# end

# Allow puma to be restarted by `rails restart` command.
if ENV["RAILS_ENV"] != "test"
  plugin :tmp_restart
end

on_worker_boot do
  if defined?(Redis)
    # The redis initializer created a pool, but we are forking to another process here and we don't
    # want to re-use the connection pool from the parent process.
    # We must configure the pool size to equal our thread count to ensure we have enough connections.
    $redis = ConnectionPool.new(size: threads_count, timeout: 5) { Redis.new(url: ENV['REDIS_DATA_URL']) }

    # The sidekiq client configuration is still going to point to the old connection pool from its initializer
    # for the same reasons above we need to reset it to the newly created pool. This will also guarantee
    # every thread in puma can get a connection to push jobs onto the queue with.
    Sidekiq.configure_client do |config|
      config.redis = $redis
    end
  end
end
