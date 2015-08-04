class ServerUser
  include Mongoid::Document
  include Mongoid::Timestamps
  # 用户名
  field :username
  # 使用过的平台
  field :used_batch_ids, type: Array, default: []
  # 最近登录,[[server_id, times]...],最近登录为最0,1,2
  field :last_login, type: Array, default: []
  # 隶属于哪个平台
  belongs_to :platform

  validates_presence_of :username, message: "必须提供用户名"

  # 更新最新登录服务器信息
  def update_last_login server_id
  	server_id = server_id.to_s unless server_id.is_a? String
    Rails.logger.debug("server_id=#{server_id}, last_login=#{last_login}")
  	#改变登录次数的排序
  	index = last_login.index{|item|item[0] == server_id}
  	item = if index
      last_login.delete_at(index)
    else
      [server_id, 0]
    end
		item[1] += 1
		last_login.unshift(item)
		self.save
  end

  def has_login_his?
    last_login.size > 0
  end

  # 最近登陆的服务器id集合
  def last_login_ids
    last_login[0..2].map{|item|item[0]}
  end

  def last_servers_data
    last_login_ids.map{|id|Server.find(id)}.select{|s|s and s.visible?}.map{|s|s.to_app_hash}
  end

end
