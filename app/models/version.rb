class Version
  include Mongoid::Document
  include Mongoid::Timestamps

  # 版本信息
  field :version
  # app端编制版本号
  field :app_version
  # 描述信息
  field :desc
  # 差异文件[{name;code;size;act}...]
  # name文件相对路径，code文件md5码，size文件大小，act加载类别
  field :diff, type: Array, default: []

  # 删除列表
  field :rm, type: Array, default: []
  # 属于那个平台
  belongs_to :platform

  validates_presence_of :version, message: "必须提供一个版本号"

end
