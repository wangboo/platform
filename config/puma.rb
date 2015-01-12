# APP_ROOT = '/home/bawang/web/platform'
APP_ROOT = "/Users/wangboo/Documents/Aptana Studio 3 Workspace/jiyu"
pidfile "#{APP_ROOT}/tmp/pids/puma.pid"
state_path "#{APP_ROOT}/tmp/pids/puma.state"
daemonize true
workers 2
threads 4,16
preload_app!