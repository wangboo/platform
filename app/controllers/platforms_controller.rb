class PlatformsController < ApplicationController

  before_action :set_platform, only: [:update]

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
    @platform = Platform.find(params[:id])
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

  def platform_params
    params.require(:platform).permit(:name, :desc, :mask, :id, :download_url, :channel_id, :channel_name, :platform, :vers)
  end


  def set_platform
    @platform = Platform.find params[:id]
  end

end
