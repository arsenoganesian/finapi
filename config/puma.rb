max_threads = ENV.fetch("RAILS_MAX_THREADS", 3).to_i
min_threads = ENV.fetch("RAILS_MIN_THREADS", 1).to_i
threads min_threads, max_threads

port ENV.fetch("PORT", 3000)

plugin :tmp_restart

pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
