class AppController < AppSideController

  def white_list
    ['218.17.158.222', '182.138.102.60']
  end

  # 服务器列表
  # 入参 mask平台标记，username用户名
  # 切智:ANDROID-ANZHI
  # 百度:ANDROID-BAIDU
  # 360:ANDROID-QIHU
  # OPPO:ANDROID-NEARME-GAMECENTER
  # 小米:ANDROID-MI
  # 豌豆荚:ANDROID-WDJ
  def server_list
    username = params[:username]
    mask = params[:mask]
    return resp_app_f "入参不正确" unless username and mask
    platform = Platform.where(mask: params[:mask]).first
    return resp_app_f "平台不存在" unless platform

    #查找用户
    server_user = ServerUser.find_or_create_by(username: username) do |user|
      # Rails.logger.debug("创建用户：#{user}")
      user.platform = platform
    end

    # 子查询可用的服务器列表
    data = {}
    data[:list] = platform.available_servers.collect{|server|server.to_app_hash}

    # Rails.logger.debug(server_user.last_login)
    # 常用服务器列表
    data[:last] = server_user.last_servers_data
    # 推荐
    if data[:last].empty? and platform.rmd_id
      data[:last] = Server.find(platform.rmd_id).to_app_hash
      data[:rmd] = 0
    end
    # 白名单测试
    # unless white_list.include? request.remote_ip
    #   data[:list].each{|d|d[:state] = 1}
    #   data[:last] = []
    #   data[:rmd] = []
    # end
    resp_app_s data
  end

# 记录手机登陆服务器
# 入参id服务器id，username用户名
def server_login
  server_id, username = params[:id], params[:username]
  return resp_app_f '入参不正确' unless server_id and username
  user = ServerUser.where(username: username).first
  return resp_app_f "用户名#{username}不存在" unless user
  return resp_app_f "服务器#{server_id}不存在" unless Server.find(server_id)
  user.update_last_login server_id
  resp_app_s
end

# 兑奖码
# 服务入参 code兑奖码， 大区mask:platform, username用户名
def validate_code
  return resp_app_f '服务入参不正确' unless params[:code] or  params[:platform] or params[:username] or params[:username].empty?
  code = params[:code]
  username = params[:username]
  # 查找并检查大区和用户名
  platform = Platform.where(mask: params[:platform]).first
  return resp_app_f '大区不存在' unless platform
  user = ServerUser.find_or_create_by(username: username, platform_id: platform.id)
  # return resp_app_f '用户名不存在' unless user

  active_code = ActiveCode.where(code: params[:code]).first
  return resp_app_f '该兑奖码不存在' unless active_code
  batch = active_code.active_batch

  # 该用户已经使用过该类型激活码了
  return resp_app_f '您已经使用过该类型兑奖码' if user.used_batch_ids.include? batch.id
  return resp_app_f '您已经使用过该类型兑奖码' if ActiveCode.where(server_user_id: user.id).collect{|code|code.active_batch.active_type_id}.include?(batch.active_type_id)
  # 该兑换码已经使用过了
  if batch.is_muti
    return resp_app_f '该激活码次数已经用完' if active_code.times == 0
    active_code.times -= 1
    active_code.save
  else
    # 单次使用
    return resp_app_f '该兑奖码已经使用过了' if active_code.use_flag
  end
  now = Time.now
  return  resp_app_f "该兑奖码还没到日期，请在#{batch.begin_time.strftime('%Y年%m月%d日')}后再来兑换" if batch.begin_time and batch.begin_time > now
  return  resp_app_f "该兑奖码已经过期" if batch.end_time and batch.end_time < now

  # 该兑换批次的大区列表中不包含用户所在大区
  unless batch.all_platform
    return resp_app_f '您的平台不能使用该兑奖码' unless batch.platforms.any?{|p|p.mask == platform.mask}
  end
  #return resp_app_f '您的平台不能使用该兑奖码' unless batch.all_platform and batch.platforms.any?{|p|p.mask == platform.mask}

  active_code.server_user = user
  active_code.use_flag = true
  active_code.update
  user.used_batch_ids << batch.id
  user.save
  resp_app_s reward: batch.reward.reward
end

# 注册
def regist
  user = QicUser.new regist_params
  # 创建失败
  return resp_app_f user.errors.messages.first[1].first unless user.save
  # 应答token
  resp_app_s
end

# 登陆
def login
  platform = Platform.where(mask: params[:mask]).first
  return resp_app_f "平台不存在" unless platform
  mac, device, version = (params[:device_info] or "0;0;0").split(";")
  # 平台统计账号
  account = Account.find_or_create_by(account_id: params[:sid], channel_id: platform.channel_id) do |a|
    a.channel_name  = platform.channel_name
    a.platform      = platform.platform
    a.vers          = platform.vers
    a.mac           = mac
    a.ip            = request.remote_ip
    a.device        = device
    a.version       = version
  end
  account.last_time = Time.now
  account.save
  case params[:mask]
  when 'ANDROID-UC'
    user, account_id = android_uc
  else
    # 默认用sid创建一个账号
    user = QicUser.find_or_create_by(username: params[:sid]) do |u|
      u.username = params[:sid]
      u.password = params[:password]
    end
    account_id = params[:sid]
  end
  if user == -1 then
    return
  end
  # 默认的处理方式
  resp_app_s account_id: account_id, sort_id: account.aid
end

def verify
  Rails.logger.debug "params=#{params}"
  resp = ::AnyServer.verify params
  Rails.logger.debug "resp=#{resp}"
  return render json: resp
end

def verify_sign
  Rails.logger.debug "params=#{params}"
  resp = AnyPayServer.verify_sign params
  return render json: resp
end

def uc_verify_sign
  resp = AnyPayServer.uc_verify_pay params
  return render json: resp
end

# 用UC account创建一个账号
def android_uc
  resp = U9Server.login params[:sid]
  unless resp['state']['code'] == 1
    resp_app_f "登陆失败"
    return [-1, 0]
  end
  account_id = resp['data']['accountId']
  user = QicUser.find_or_create_by(username: account_id) do |u|
    u.username = account_id
    u.password = params[:password]
  end
  [user, account_id]
end
#   随机用户
def random_user
  while(true)
    name = 10000 + rand(89999)
    name = name.to_s
    break unless QicUser.where(username: name).exists?
  end
  pwd = 1000 + rand(8999)
  pwd = pwd.to_s
  resp_app_s username: name, password: pwd
end

def regist_params
  params.permit(:username, :password)
end

# flist 缓存
# {platform_mask: "flist"}
@@flist_cache = {}

def self.flist_cache
  @@flist_cache
end

# 指定平台的flist文件
def flist
  mask = params[:platform]
  platform = Platform.find_by(mask: mask)
  last_version = platform.versions.last
  unless last_version
    last_version = Version.new
    last_version.version = '0.0.0'
    last_version.app_version = '0.0.0'
    last_version.platform = platform
    last_version.diff = []
  end
  # VersionsController.save_flist last_version unless @@flist_cache.include? mask
  VersionsController.save_flist last_version
  render json: @@flist_cache[mask]
end

# 上传客户端异常信息
def errlog
  username = params[:username]
  error = params[:error]
  error = Base64.decode64 error
  # Rails.logger.debug "error #{error}"
  server_id = params[:server_id]
  ErrorLog.create(
  username: username,
  error: error,
  server_id: server_id
  )
  resp_app_s
end

def data
  platform = Platform.where(mask: params[:mask]).first
  resp_app_s platform.json_data
end

end
