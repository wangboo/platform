# 平台，一个平台可以有多个服务器
class Platform
  include Mongoid::Document
  include Mongoid::Timestamps
	# app端辨别的标记
	field :mask
  field :name
  field :desc
  # 更新url
  field :download_url

  # 第三方sdk通道id
  field :channel_id
  # 第三方sdk通道名
  field :channel_name
  # 平台名字 IOS = 1, Android = 2
  field :platform, type: Integer
  # 游戏版本号
  field :vers
  # 推荐服务器
  field :rmd_id
  # has_one :rmd, class_name: "Server"
  
  has_many :servers, dependent: :destroy

  has_many :versions, dependent: :destroy
  
  # 可用的平台
  def available_servers
    servers.select{|s|s.visible?}
  end

  def json_data
    {name: name, channel_id: channel_id, channel_name: channel_name, platform: platform,vers: vers}
  end

end
