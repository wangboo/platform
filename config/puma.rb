# APP_ROOT = '/home/bawang/web/platform'
APP_ROOT = "/home/platform/platform_server"
#bind "tcp://#{APP_ROOT}/tmp/puma.sock"
pidfile "#{APP_ROOT}/tmp/pids/puma.pid"
state_path "#{APP_ROOT}/tmp/pids/puma.state"
daemonize true
workers 4
threads 8,16
preload_app!
#environment 'production'
