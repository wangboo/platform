class AppController < AppSideController

  def white_list
    ['182.138.102.60', '182.139.182.238', '110.184.65.95']
  end

  def un_block_list
    ['IOS-XUNQIN-KY']
    #['ANDROID-UC']
  end
  def block_list
    ['ANDROID-XICHU-MI', 'ANDROID-XICHU-BAIDU', 'ANDROID-XICHU-QIHU']
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

    if manage = Manage.first
      # ip限制
      puts "request.remote_ip = #{request.remote_ip}"
      return resp_app_f manage.white_ips_notice if manage.white_ips_on and not manage.white_ips.include?(request.remote_ip)
      # 平台限制
      return resp_app_f manage.white_platform_notice if manage.white_platform_on and not manage.white_platform.include?(mask)
    end

    #查找用户
    server_user = ServerUser.find_or_create_by(username: username) do |user|
      # Rails.logger.debug("创建用户：#{user}")
      user.platform = platform
    end
    # 子查询可用的服务器列表
    data = {}
    data[:list] = platform.available_servers.sort{|a,b|(b.zone_id||0) <=> (a.zone_id||0)}.collect{|server|server.to_app_hash}

    # Rails.logger.debug(server_user.last_login)
    # 常用服务器列表
    data[:last] = server_user.last_servers_data
    # 推荐
    if data[:last].empty? and platform.rmd_id
      data[:last] = [Server.find(platform.rmd_id).to_app_hash]
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
    return validate_code_old unless params[:code] =~ /^[a-zA-Z]/
    return resp_app_f '服务入参不正确' unless params[:code] or  params[:platform] or params[:username] or params[:username].empty?
    return resp_aff_f "缺少入参zoneId" unless params[:zoneId]

    mask, zone_id,code,username = params[:platform], params[:zoneId].to_i,params[:code],params[:username]
    # 查找并检查大区和用户名
    platform = Platform.where(mask: mask).first
    return resp_app_f '大区不存在' unless platform
    # server = platform.servers.where(zone_id: zone_id).first
    # return resp_app_f '服务器不存在' unless server
    user = ServerUser.find_or_create_by(username: username, platform_id: platform.id)
    # return resp_app_f '用户名不存在' unless user
    active_code = ActiveCode.where(code: code).first
    return resp_app_f '该兑奖码不存在' unless active_code
    batch = active_code.active_batch
    # 查询使用记录
    record_size = UserAcRecord.where(user_id: user.id, active_batch_id: batch.id, zone_id: zone_id).size
    return resp_app_f "你已经使用过该类型激活码了" if record_size > 0
    record_size = UserAcRecord.where(user_id: user.id, active_type_id: batch.active_type.id, zone_id: zone_id).size
    return resp_app_f "你已经使用过该类型激活码了" if record_size > 0

    # 该兑换批次的大区列表中不包含用户所在大区
    unless batch.all_platform
      logger.debug "batch.platforms = #{batch.platform_masks}"
      return resp_app_f '该平台不能使用该兑奖码' unless batch.platform_masks.include? mask
    end
    # 判断服务器是否在允许列表中
    unless batch.all_server
      logger.debug "batch.zone_ids = #{batch.zone_ids} zone_id = #{zone_id}"
      return resp_app_f '该服不能使用该兑奖码' unless batch.zone_ids.include? zone_id
    end
    # 过期判断
    now = Time.now
    return  resp_app_f "该兑奖码还没到日期，请在#{batch.begin_time.strftime('%Y年%m月%d日')}后再来兑换" if batch.begin_time and batch.begin_time > now
    return  resp_app_f "该兑奖码已经过期" if batch.end_time and batch.end_time < now

    # 该兑换码已经使用过了
    if batch.is_muti
      return resp_app_f '该激活码次数已经用完' if active_code.times == 0
      active_code.times -= 1
    else
      # 单次使用
      return resp_app_f '该兑奖码已经使用过了' if active_code.use_flag
    end
    # 使用
    active_code.use_flag = true
    active_code.update
    UserAcRecord.create(user_id: user.id, active_batch_id: batch.id, zone_id: zone_id,
      active_code_id: active_code.id, code: active_code.code, active_type_id: batch.active_type.id)
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
    Rails.logger.debug "params ===#{params}"
    platform = Platform.where(mask: params[:mask]).first
    return resp_app_f "平台不存在" unless platform
    mac, device, version = (params[:device_info] or "0;0;0").split(";")
    # 平台统计账号
    account = Account.find_or_create_by(account_id: params[:uid], channel_id: platform.channel_id) do |a|
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
    Rails.logger.debug "mask=#{params[:mask]}"
    case params[:mask]
    when 'ANDROID-XUNQIN-UC'
      user, account_id = android_uc
    when 'IOS-ICE'
      user, account_id = ios_i4
      # when 'IOS-BAIDU'
      # user, account_id = ios_baidu
    when 'IOS-XUNQIN-PP'
      user, account_id = ios_pp
    when 'GB'
      user,account_id = game_begin
    when 'IOS-TONGBU'
      user,account_id = ios_tongbu
    when /\-MUD/
      user,account_id = MudController.login params[:token], request.remote_ip
    when /KY/
      user,account_id = ios_ky
    else
      # 默认用sid创建一个账号
      user = QicUser.find_or_create_by(username: params[:sid]) do |u|
        u.username = params[:sid]
        u.password = params[:password]
      end
      account_id = params[:sid]
    end
		logger.debug "user=#{user}, account = #{account_id}"
    if user == -1 then
      return resp_app_f
    end
    account.account_id=account_id
    account.save
		logger.debug "save account #{account}"
    # 默认的处理方式
    resp_app_s account_id: account_id, sort_id: account.aid
  end

# app_controller.rb
  #保存minisdk的bpuid
  def login_mini
    bpUID=params['bpUID']
    account = Account.find_by account_id: params['accountId']
    if nil !=account
      account.bpuid = bpUID
      account.save
    end
    render json: "ok"
  end
  #获取Uid给游戏服务器使用
  def get_uid
    account=Account.find_by account_id: params['accountId']
    return render json: '0' unless account
    return render json: "0" if account.bpuid.empty?
    render json: (account.bpuid or '0')
  end

  def verify
    Rails.logger.debug "params=#{params}"
    resp = ::Any.verify params
    Rails.logger.debug "resp=#{resp}"
    data = resp['common']
    Account.find_or_create_by(account_id: data['uid']) do |a|
      a.channel_id  = data['channel']
    end
    return render json: resp
  end

  def verify_sign
    Rails.logger.debug "params=#{params}"
    resp = AnyPay.verify_sign params
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

  def ios_tongbu
   sid, token = params[:sid], params[:token]
   user = if TongbuController.login token
      QicUser.find_or_create_by(username: sid)
  else
   resp_app_f "验证失败"
   -1
  end
   [user, sid]
  rescue => e
    resp_app_f _m: "验证失败 #{e}"
    [-1, 0]
  end

  def game_begin
    begin
      body = GameBeginController.login params
      unless JSON.parse(body)['Result'].to_i == 1
        resp_app_f "登陆失败"
        return [-1, 0]
      end
    rescue
      resp_app_f "登陆失败"
      return [-1, 0]
    end
    Rails.logger.debug "params username=#{params[:uid]}"
    user = QicUser.find_or_create_by(username: params[:uid]) do |u|
      u.username= params[:uid]
      # u.password = params[:password]
    end
    [user, params[:uid]]
  end

  def ios_i4
    begin
      body = HTTParty.post("https://pay.i4.cn/member_third.action", token: params[:token]).body
      return [-1, 0] unless JSON.parse(body)['status'] == 0
    rescue
      return [-1, 0]
    end
    user = QicUser.find_or_create_by(username: params[:sid]) do |u|
      u.password = params[:password]
    end
    [user, params[:sid]]
  end

  # pp助手
  def ios_pp
    resp = PpController.login params[:token]
    resp = JSON.parse resp
    Rails.logger.debug "resp = #{resp}"
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

  def ios_ky
    resp = KyController.login params[:token]
    resp = JSON.parse resp
    Rails.logger.debug "resp = #{resp}"
    unless resp['code'] == 0
      resp_app_f "登陆失败"
      return [-1, 0]
    end
    account_id = resp['data']['guid']
    user = QicUser.find_or_create_by(username: account_id) do |u|
      u.password = params[:password]
    end
    [user, account_id]
  end

  # 百度登陆
  # def ios_baidu
  # end

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

  # 通过账号查询平台
  def find_platform
    user = ServerUser.where(username: params[:username]).first
    return resp_app_f "账号不存在" unless user
    resp_app_s mask: user.platform.mask
  end

  # role_id, product_id, server_id, platform
  def get_order_no
    return resp_app_f "找不到对应的服务器" unless Server.where(id: params[:serverId]).exists?
    order_id = JiyuOrder.generate_order(params[:userId], params[:productId], params[:serverId], params[:platform]).order_id
    Rails.logger.debug "create order #{order_id}"
    resp_app_s order_id: order_id
  end

  private
  def validate_code_old
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
  return resp_app_f '您已经使用过该类型兑奖码' if ActiveCode.where(server_user_id: user.id).collect{|code|code.active_batch.active_type.id}.include?(batch.active_type.id)
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
  # return resp_app_f '您的平台不能使用该兑奖码' unless batch.platforms.any?{|p|p.mask == platform.mask}

  active_code.server_user = user
  active_code.use_flag = true
  active_code.update
  user.used_batch_ids << batch.id
  user.save
  resp_app_s reward: batch.reward.reward
end

end
