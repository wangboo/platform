# APP_ROOT = '/home/bawang/web/platform'
<<<<<<< HEAD
APP_ROOT = "/home/platform/web/platform"
#bind "tcp://#{APP_ROOT}/tmp/puma.sock"
=======
APP_ROOT = "/Users/wangboo/Documents/Aptana Studio 3 Workspace/jiyu"
>>>>>>> 833f4aad7b008cbeb5e43c400df3a893a2d85921
pidfile "#{APP_ROOT}/tmp/pids/puma.pid"
state_path "#{APP_ROOT}/tmp/pids/puma.state"
daemonize true
workers 2
threads 4,16
<<<<<<< HEAD
preload_app!
=======
preload_app!
>>>>>>> 833f4aad7b008cbeb5e43c400df3a893a2d85921
