require_dependency Rails.root.join("lib", "comm.rb")
class ServersController < ApplicationController

  before_action :find_server, only: [:show, :update, :user_range, :user_active, :use_gold]

  def find_server
    @server = Server.find(params[:id])
  end

  def love
    render :love, layout: false
  end

  def show
  end

  def create
    Server.create server_params
    redirect_to servers_path
  end

  def update
    @server.update(server_params)
    redirect_to platform_server_path(@server.platform, @server)
  end

  def delete
  end

  def server_params 
    params.require("server").permit(:name, :desc, :ip, :port, :platform_id, :server_state_id, :work_state, :zone_id,
      :ssh_user, :ssh_pwd, :project_path, :mysql_user, :mysql_pwd, :mysql_database, :mysql_host)
  end

  # 服务器在线人数, json请求

  def index
    @servers = Server.all.order(platform_id: :asc, created_at: :asc)
    @new_server = Server.new
  end

# 查询该服务器信息
  def server_info 
    server = Server.find(params[:id])
    Rails.logger.debug "ip=#{server.ip},port=#{server.port}"
    rst = GameServer.call_cmd(server, "server_info")
    Rails.logger.debug rst
    render json: rst
  end

  # 报表服务
  # 用户区间
  def user_range
    @data = JSON.parse(GameServer.call_cmd(@server, "user_range"))["list"]
  end

  # 活跃区间
  def user_active
    @data = JSON.parse(GameServer.call_cmd(@server, "user_active"))["list"]
  end

  # 使用元宝报表（包含使用、产出，元宝，代金券）
  def use_gold
    last = nil
    @data = find_chat_data.inject([]) do |sum, item|
      if last
        hash = {time: item.time.to_s[8,2], 
          # goldSum: last.goldSum - item.goldSum, 
          goldSum: item.goldSum, 
          donateSum: last.donateSum - item.donateSum, 
          voucherSum: last.voucherSum - item.voucherSum,
          goldCost: last.goldCost - item.goldCost, 
          voucherCost: last.voucherCost - item.voucherCost, 
          donateCost: last.donateCost - item.donateCost,
          server_id: item.server_id}
        sum << hash
      end
      last = item
      sum
    end
    @date = params[:begin] || Time.now.strftime('%Y%m%d')
    Rails.logger.debug(@data)
  end

  def find_chat_data
    date = params[:begin] || Time.now.strftime('%Y%m%d')
    year = date[0,4].to_i
    month = date[4,2].to_i
    day = date[6,2].to_i
    # begin_date = (Time.new(year, month, day).yesterday+23.hours).strftime("%Y%m%d%H")
    begin_date = (Time.new(year, month, day).yesterday+23.hours)
    end_date = (begin_date + 24.hours).strftime("%Y%m%d%H").to_i
    begin_date = begin_date.strftime("%Y%m%d%H").to_i
    
    # ServerInfo.where("date between ? and ?", begin_date, end_date).select(select_params)
    ServerInfo.where(time: begin_date..end_date, server_id: params[:id])
  end

end
