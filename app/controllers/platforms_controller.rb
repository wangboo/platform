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

  def delete
  end

  def platform_params
    params.require(:platform).permit(:name, :desc, :mask, :id, :download_url, :channel_id, :channel_name, :platform, :vers)
  end


  def set_platform
    @platform = Platform.find params[:id]
  end

end
