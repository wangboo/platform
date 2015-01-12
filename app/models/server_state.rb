# 服务器状态
class ServerState
  include Mongoid::Document
# 状态名
  field :name
# app端显示
	field :show
# 描述
  field :desc
end
