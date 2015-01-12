# APP_ROOT = '/home/bawang/web/platform'
APP_ROOT = "/home/platform/web/platform"
#bind "tcp://#{APP_ROOT}/tmp/puma.sock"
pidfile "#{APP_ROOT}/tmp/pids/puma.pid"
state_path "#{APP_ROOT}/tmp/pids/puma.state"
daemonize true
workers 2
threads 4,16
preload_app!
