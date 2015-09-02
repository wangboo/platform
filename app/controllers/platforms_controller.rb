class PlatformsController < ApplicationController

  before_action :set_platform, only: [:update, :tongbu_p2p]

  # 创建一个平台
  def create
    platform = Platform.new platform_params
    respond_to do |format|
      platform.save
      format.html{redirect_to platforms_path}
    end
  end

  def show
    Rails.logger.debug("params=#{params}")
    params_id = params[:id]
    @platform = Platform.find(params_id)
    @platform_id_names = Platform.all.pluck(:name, :id).map{|pair|pair[1] = pair[1].to_s;pair}.select{|name, id| id != params_id}
    @rmd = Server.find(@platform.rmd_id) if @platform.rmd_id 
  end

  def index
    @platforms = Platform.all.order("id asc")
    @new_platform = Platform.new
  end

  def update
    # Rails.logger.debug "update platform = #{@platform_params}"
    # @platform.rmd_id = params[:platform][:rmd_id]
    @platform.update platform_params
    render action: :show
  end

  def kf_view
    @platform = Platform.find(params[:platform_id])
    @all_states = ServerState.all
    # end
  end

  def kf
    platform = Platform.find(params[:platform_id])
    server = Server.find(params[:kf_id])
    platform.rmd_id = server.id
    platform.save
    render json: {rst: "ok"}
  end

  # 设置游戏server_state状态
  def kf_server_state
    server = Server.find(params[:s_id])
    server_state = ServerState.find(params[:state_id])
    server.server_state_id = server_state.id
    server.save
    render json: {rst: "ok"}
  end

  # 改变服务器状态
  def kf_ws
    # platform = Platform.find(params[:platform_id])
    server = Server.find(params[:s_id])
    work_state = params[:ws].to_i
    return render json: {rst: "work_state=#{work_state}不合法"} unless [0,1,2].include?(work_state)
    server.work_state = work_state
    server.save 
    render json: {rst: "ok"}
  end

  # 将推荐服务器设置为所有平台的推荐
  def kf_all_rmd_the_same
    platform = Platform.find(params[:platform_id])
    return render json: {rst: "该平台推荐服务器还未设置"} unless platform.rmd_id 
    server = Server.find(platform.rmd_id)
    # Rails.logger.debug "server = #{server.name}"
    msg = []
    Server.where(ip: server.ip, port: server.port).each do |s|
      # Rails.logger.debug "set #{s.name} is rmd_id to platform #{s.platform.name}"
      s.platform.rmd_id = s.id
      s.work_state = server.work_state
      s.server_state_id = server.server_state_id
      s.zone_id = server.zone_id
      s.platform.save
      s.save
      msg << "#{s.platform.name}"
    end
    render json: {rst: "#{msg.join(",")} => ok"}
  end
  # 将该平台的所有配置设置为所有平台的配置
  def kf_all_the_same
    platform = Platform.find(params[:platform_id])
    platform.servers.each do |ps|
      Server.where(ip: ps.ip, port: ps.port).update_all(work_state: ps.work_state, server_state_id: ps.server_state_id, zone_id: ps.zone_id)
    end
    kf_all_rmd_the_same
  end

  # 停服
  def kf_tf 
    return render json: {ok: false, msg: "密码错误"} unless params['pwd'] == 'w231520'
    @platform = Platform.find params[:platform_id]
    # rst = []
    @platform.servers.each do |s|
      Thread.new do 
        HTTParty.get(s.stop_server_url)
      end
    end
    render json: {ok: true, msg: "停服成功"}
  end

  def delete
  end

  # 将该平台服务器同步至to平台
  def tongbu_p2p
    to_platform_id = params[:to]
    rst = {create: 0, update: 0}
    @platform.servers.each do |s|
      ip, port, name, zone_id = s.ip, s.port, s.name, s.zone_id
      new_server = false 
      to_server = Server.find_or_create_by(platform_id: to_platform_id, ip: ip, port: port) do 
        rst[:create] += 1
        new_server = true 
      end
      unless to_server.name == name and to_server.zone_id == zone_id 
        to_server.update_attributes(
          name:         name, 
          zone_id:      zone_id, 
          desc:         s.desc,
          ssh_user:     s.ssh_user,
          ssh_pwd:      s.ssh_pwd,
          project_path: s.project_path,
          mysql_user:   s.mysql_user,
          mysql_pwd:    s.mysql_pwd,
          mysql_host:     s.mysql_host,
          mysql_database: s.mysql_database,
          local_ip:     s.local_ip,
          work_state:   s.work_state, 
          server_state: s.server_state)
        rst[:update] += 1 unless new_server
      end
    end
    render json: rst
  end

  def platform_params
    params.require(:platform).permit(:name, :desc, :mask, :id, :download_url, :channel_id, :channel_name, :platform, :vers)
  end


  def set_platform
    @platform = Platform.find((params[:id] or params[:platform_id]))
  end

end
