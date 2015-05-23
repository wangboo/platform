class Server
  include Mongoid::Document
  include Mongoid::Timestamps
  #服务器名字
  field :name
  # 服务器id
  field :zone_id, type: Integer
  #服务器描述
  field :desc
  #服务器ip
  field :ip
  #服务器端口
  field :port, type: Integer
  #服务器可用状态 0 可见&可用，1可见&不可用，2不可见&不可用
  field :work_state, type: Integer, default: 0

  field :ssh_user
  field :ssh_pwd
  field :project_path
  field :mysql_user
  field :mysql_pwd
  field :mysql_host
  field :mysql_database
  # 内网网卡ip
  field :local_ip
  # 隶属于平台
  belongs_to :platform
  # 推荐
  # belongs_to :rmd, class_name: "Platform"
  # 隶属于一个服务器状态
  belongs_to :server_state

  validates_presence_of :ip, message: "ip地址不能为空"

  validates_presence_of :port, message: "端口不能为空"

  validates_presence_of :name, message: "服务器名字不能为空"

  # 服务器状态可以显示
  def visible?
    work_state == 0 or work_state == 1
  end

  def query_notice_url
    "http://#{ip}:#{port}/jiyu/admin/tools/queryNotice"
  end

  def update_notice_url
    "http://#{ip}:#{port}/jiyu/admin/tools/modifyNotice"
  end

  def ar_option 
    {adapter: "mysql2", host: local_ip, username: mysql_user, password: mysql_pwd, database: mysql_database}
  end

  def to_app_hash
    {
      name: name, 
      ip: ip, 
      port: port, 
      show: server_state.show, 
      state: work_state, 
      id: self.id.to_s, 
      desc: desc,
      zone_id: zone_id
    }
  end

  def tools_params
    {mysql_user: mysql_user, mysql_pwd: mysql_pwd, mysql: mysql_host, mysql_db: mysql_database}
  end

  def daily_charge_info_url
    "http://#{ip}:#{port}/jiyu/admin/master/dailyChargeInfo"
  end

  def charge_info_user_url
    "http://#{ip}:#{port}/jiyu/admin/master/userChargeInfo"
  end

  def stop_server_url
    "http://#{ip}:#{port}/jiyu/admin/master/shutdown?pwd=w231520&time=10"
  end

end