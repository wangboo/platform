Rails.application.routes.draw do

  # 获得 /fonts/*  字体
  get '/fonts/:name', to: lambda{|p|
    puts p['REQUEST_URI'].match(/^\/fonts\/(.*)$/)[1]
    fonts = Rails.root.join("app","assets","fonts",p['REQUEST_URI'].match(/^\/fonts\/(.*)$/)[1])
    puts "fonts = #{fonts}"
    data = File.open(fonts){|f|f.read}
    [200, {"Content-Type" => "application/fonts"}, [data]]
  }

  root "platforms#index"

  get '/auth/login' => 'auth#login', as: "auth_view"
  # 登陆动作
  post '/auth/login' => 'auth#validate', as: "auth_login"

  get '/auth/logout' => 'auth#logout', as: "auth_logout"

  # app端服务
  # 验证并使用奖励码
  get "/app/validate_code" => "app#validate_code"
  # 登陆服务器列表信息
  get "/app/list" => "app#server_list"
  # 登陆服务器记录
  get "/app/login_his" => "app#server_login"
  # 注册
  get "/app/regist" => "app#regist"
  # 登陆
  get "/app/login" => "app#login"
  #any sdk
  post "/app/verify" => "app#verify"
  post "/app/verify_pay" => "app#verify_sign"
  post "/app/uc_verify_pay" => "app#uc_verify_sign"

  post "/app/haima_verify_pay" => "haima#verify_pay"
  # flist 入参platform 平台码
  get "/app/flist" => "app#flist"
  
  get "/app/random" => "app#random_user"

  # 服务端验证账号和token
  get "/gs/applogin" => "game_servers#applogin"
  # 异常信息
  get '/app/errlog' => "app#errlog"
  # 查询大区信息
  get '/app/data'   => "app#data"

  post '/app/find_platform' => 'app#find_platform'

  get '/app/getOrderNo' => 'app#get_order_no'


  # web端服务
  # 服务器列表
  get "/login"   => 'auth#login'

  get "/servers" => "servers#index", as: "server_index"
  # 新建服务器 
  post "/servers" => "servers#create"
  # 服务器，查看用户区间
  get "/servers/:id/user_range" => "servers#user_range", as: "server_user_range"
  # 服务器，查看用户活跃时间区间
  get "/servers/:id/user_active" => "servers#user_active", as: "server_user_active"
  # 使用元宝报表（包含使用、产出，元宝，代金券）
  get "/servers/:id/use_gold" => "servers#use_gold", as: "server_use_gold"
  # 显示某个平台的版本信息
  get "/versions/:id" => "versions#show", as: "version"
  # 创建版本界面
  get "/versions/:id/new" => "versions#new", as: "new_version"
  # 创建action
  post "/versions/:id" => "versions#create", as: "create_version"
  # 查看差异文件
  get "/versions/:id/diff" => "versions#diff", as: "diff_version"
  # 查看flist文件
  get "/versions/:id/flist" => "versions#flist", as: "flist_version"
  # 编辑version
  get "/versions/:id/edit"  => "versions#edit", as: "edit_version"
  # 更新version id为version.id
  patch "/versions/:id"      => "versions#update", as: "update_version"
  # 异常日志
  get "/err_app" => "error_log#index", as: "error_log"
  # 标记解决异常
  get "/err_app/resove" => "error_log#resove", as: "error_log_resove"

  # post "/err_app" => "error_log#index", as: "error_log"

  # resources :versions, only: [:show]

  get "/test" => "versions#test"


  # 兑奖码
  resources :rewards
  # 兑奖码批次
  resources :active_batches do 
    # get '/download', action: "download"
  end

  get "active_batches/:id/download" => "active_batches#download", as: "active_batch_download"
  # 兑奖类型
  resources :active_types, only: [:index, :update, :create, :delete]
  # 服务状态
  resources :server_states, only: [:index, :update, :create]

  # 每月签到奖励列表
  resources :month_rewards
  # 平台
  resources :platforms do
    resources :servers
    get '/kf', action: :kf_view, as: "kf_view"
    post '/kf', action: :kf, as: "kf"
    # 改变server_state
    post '/kf_ws', action: :kf_ws, as: "kf_ws"
    # 设置游戏server_state状态
    post "kf_ss", action: :kf_server_state, as: "kf_ss"
    # 将推荐服务器设置为所有平台的推荐
    post '/kf_rmd_all', action: :kf_all_rmd_the_same, as: "kf_rmd_all"
    # 将该平台的所有配置设置为所有平台的配置
    post '/kf_all', action: :kf_all_the_same, as: "kf_all"
  end

  get "/platforms/:id/tools" => "tools#reward_to_user_view", as: "tools"
  # 管理平台  发奖品 给指定用户
  post "/platforms/:id/tools/reward/to_user" => "tools#reward_to_user", as: "tools_reward_to_user"
  # 管理平台  发奖品 指定条件界面
  get "/platforms/:id/tools/reward/to_condition" => "tools#reward_to_condition_view", as: "tools_reward_to_condition_view"
  # 管理平台  发奖品 指定条件
  post "/platforms/:id/tools/reward/to_condition" => "tools#reward_to_condition", as: "tools_reward_to_condition"

  get "/platforms/:id/tools/reward/to_platform" => "tools#reward_to_platform_view", as: "tools_reward_to_platform_view"

  post "/platforms/:id/tools/reward/to_platform" => "tools#reward_to_platform", as: "tools_reward_to_platform"

  # 公告
  get "/platforms/:id/tools/notice" => "tools#notice_view", as: "tools_notice_view"
  # 发公告
  post "/platforms/:id/tools/notice" => "tools#create_notice", as: "tools_create_notice"
  # 公告
  get "/platforms/:id/tools/scroll_msg" => "tools#scroll_msg_view", as: "tools_scroll_msg_view"
  # 发公告
  post "/platforms/:id/tools/scroll_msg" => "tools#scroll_msg", as: "tools_scroll_msg"

  # ajax请求
  # 服务器信息
  get "/ajax/server/info" => "servers#server_info", as: "ajax_server_info"
  # 删除verion中的一项
  get '/ajax/version/:id/del_diff' => "versions#del_diff_item", as: "ajax_version_del_diff_item"
  # 调试工具
  get '/web-console' => "tools#web_console" 
  # 游戏玩家用户数
  post '/server/:id/usersize' => "servers#usersize", as: "ajax_server_usersize"

end
