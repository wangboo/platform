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

  def to_app_hash
    {
      name: name, 
      ip: ip, 
      port: port, 
      show: server_state.show, 
      state: work_state, 
      id: self.zone_id, 
      desc: desc
    }
  end

  def tools_params
    {mysql_user: mysql_user, mysql_pwd: mysql_pwd, mysql: mysql_host, mysql_db: mysql_database}
  end

end