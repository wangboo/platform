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
  #mini login
  get "/app/login_mini" => "app#login_mini"
  #获取Uid
  get  "app/get_uid" => "app#get_uid"
  post "app/get_uid" => "app#get_uid"
  # 天拓支付
  get '/app/tt_verify_pay' => 'tt#verify_pay'
  post '/app/tt_verify_pay' => 'tt#verify_pay'
  #any sdk
  post "/app/verify" => "app#verify"
  post "/app/verify_pay" => "app#verify_sign"
  get "/app/verify_pay" => 'app#verify_sign'
  post "/app/uc_verify_pay" => "uc#uc_verify_sign"
  # 海马支付
  post "/app/haima_verify_pay" => "haima#verify_pay"
  # itools 支付
  post "/app/itools_verify_pay" => "itools#verify_pay"
  # i4 支付
  post "/app/i4_verify_pay" => "i4#verify_pay"
  # 百度支付
  get "/app/baidu_verify_pay" => "baidu#verify_pay"
  #华为支付
  get "/app/huawei_verify_pay" => "huawei#verify_pay"
  # pp助手
  post "/app/pp_verify_pay"   => 'pp#verify_pay'
  # xy 支付
  post '/app/xy_verify_pay'  => 'xy#verify_pay'
  # ky 支付
  post '/app/ky_verify_pay'  =>  'ky#verify_pay'
  # tongbu 支付
  get '/app/tongbu_verify_pay' => 'tongbu#verify_pay'
  # iiapple
  post '/app/iiapple_verify_pay' => 'iiapple#verify_pay'
  get '/app/gb_verify_pay' => 'game_begin#verify_pay'

  post '/app/mogoo_verify_pay' => 'mogoo#verify_pay'
  # ios 充值
  get '/app/iap_verify' => 'iap#verify_pay'
  # asdk
  post '/app/asdk_verify_pay' => 'asdk#verify_pay'
  # 泥巴充值
  post '/app/mud_verify_pay' => 'mud#verify_pay'
 #快发充值
  post '/app/kf_verify_pay' => 'kuaifa#verify_pay'
  # flist 入参platform 平台码
  get "/app/flist" => "app#flist"

  get "/app/random" => "app#random_user"

  # 服务端验证账号和token
  get "/gs/applogin" => "game_servers#applogin"
  # 异常信息
  get '/app/errlog' => "app#errlog"
  # 查询大区信息
  get '/app/data'   => "app#data"

  post '/app/find_platform/:username' => 'app#find_platform'

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

  # 平台管理，开服，停服，ip白名单等
  resources :manage
  # ip白名单
  post "/ajax/manage/update_white_ips" => "manage#update_white_ips", as: "manage_update_white_ips"
  post "/ajax/manage/update_white_ips_on" => "manage#update_white_ips_on", as: "manage_update_white_ips_on"
  post '/ajax/manage/update_white_ips_notice' => 'manage#update_white_ips_notice', as: "manage_update_white_ips_notice"

  post "/ajax/manage/update_white_platform" => 'manage#update_white_platform', as: "manage_update_white_platform"
  post "/ajax/manage/update_white_platform_all" => 'manage#update_white_platform_all', as: "manage_update_white_platform_all"
  post "/ajax/manage/update_white_platform_on" => 'manage#update_white_platform_on', as: "manage_update_white_platform_on"
  post '/ajax/manage/update_white_platform_notice' => 'manage#update_white_platform_notice', as: "manage_update_white_platform_notice"
  # 兑奖码
  resources :rewards
  # 兑奖码批次
  resources :active_batches

  get "active_batches/:id/download" => "active_batches#download", as: "active_batch_download"
  # 兑奖类型
  resources :active_types, only: [:index, :update, :create, :delete]
  # 服务状态
  resources :server_states, only: [:index, :update, :create]

  # 每月签到奖励列表
  resources :month_rewards
  # 平台
  resources :platforms do
    resources :servers do
      get '/charge', action: :charge_info, as: "charge_info"
      get '/charge/user/:user_id', action: :charge_info_user, as: "charge_info_user"
      get '/delete', action: :delete, as: "delete"
    end
    get '/kf', action: :kf_view, as: "kf_view"
    post '/kf', action: :kf, as: "kf"
    post '/kf_tf', action: :kf_tf, as: "kf_tf"
    # 改变server_state
    post '/kf_ws', action: :kf_ws, as: "kf_ws"
    # 设置游戏server_state状态
    post "kf_ss", action: :kf_server_state, as: "kf_ss"
    # 将推荐服务器设置为所有平台的推荐
    post '/kf_rmd_all', action: :kf_all_rmd_the_same, as: "kf_rmd_all"
    # 将该平台的所有配置设置为所有平台的配置
    post '/kf_all', action: :kf_all_the_same, as: "kf_all"
    # 将A平台同步至B平台
    post '/tongbu_p2p/:to', action: :tongbu_p2p, as: "tongbu_p2p"
  end

  get '/groups' => 'group#index', as: "groups_index"
  post '/groups' => 'group#create', as: "new_group"
  get '/groups/:id' => 'group#show', as: "group_show"
  get '/groups/:id/delete' => 'group#delete', as: "group_delete"
  get '/group/:id/rmplatform/:pid' => 'group#rmplatform', as: "group_rmplatform"
  get '/group/:id/addplatform/:pid' => 'group#addplatform', as: "group_addplatform"
  # 修改名字
  post '/group/:id' => 'group#update', as: "group_update"

  resources :bgm

  get "/platforms/:id/tools" => "tools#reward_to_user_view", as: "tools"
  # 管理平台  发奖品 给指定用户
  post "/platforms/:id/tools/reward/to_user" => "tools#reward_to_user", as: "tools_reward_to_user"
  # 管理平台  发奖品 指定条件界面
  get "/platforms/:id/tools/reward/to_condition" => "tools#reward_to_condition_view", as: "tools_reward_to_condition_view"
  # 管理平台  发奖品 指定条件
  post "/platforms/:id/tools/reward/to_condition" => "tools#reward_to_condition", as: "tools_reward_to_condition"

  get "/platforms/:id/tools/reward/to_platform" => "tools#reward_to_platform_view", as: "tools_reward_to_platform_view"

  post "/platforms/:id/tools/reward/to_platform" => "tools#reward_to_platform", as: "tools_reward_to_platform"

  get "/platforms/:id/tools/unsend" => 'tools#unsend_view', as: "tools_reward_unsend_view"

  get "/platforms/:id/tools/send" => 'tools#send_view', as: "tools_reward_send_view"

  post '/json/delete_job' => 'tools#delete_job', as: "tools_delete_job"
  # 公告
  get "/platforms/:id/tools/notice" => "tools#notice_view", as: "tools_notice_view"
  # 发公告
  post "/platforms/:id/tools/notice" => "tools#create_notice", as: "tools_create_notice"
  # 查询公告
  get "/platforms/:id/tools/notice_modify" => "tools#notice_modify_view", as: "tools_notice_modify_view"
  # 公告
  post "/platforms/:id/tools/notice_modify" => "tools#notice_modify", as: "tools_notice_modify"
  # 公告
  get   "/platforms/:id/tools/scroll_msg" => "tools#scroll_msg_view", as: "tools_scroll_msg_view"
  # 发公告
  post  "/platforms/:id/tools/scroll_msg" => "tools#scroll_msg", as: "tools_scroll_msg"
  # 批量执行url任务
  get   '/platforms/:id/tools/batch_url'  =>  "tools#batch_url_view", as: "tools_batch_url_view"
  # 批量执行url
  post  '/platforms/:id/tools/batch_url'  =>  'tools#batch_url', as: 'tools_batch_url'

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
