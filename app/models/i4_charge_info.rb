# 爱思充值
class I4ChargeInfo
	include Mongoid::Document
 	include Mongoid::Timestamps

 	# 兑换订单号
 	field :order_id
 	# 厂商订单号(原样返回给游戏服)
 	field :billno
 	# 通行证账号
 	field :account
 	# 兑换爱思币数量
 	field :amount
 	# 状态: 0 正常状态 1 已兑换过并成功返回
 	field :status, type: Integer
 	# 厂商应用 ID(原样返回给游戏服)
 	field :app_id
 	# 厂商应用角色 id(原样返回给游戏服)
 	field :role
 	# 厂商应用分区 id(原样返回给游戏服)
 	field :zone

 	# 游戏服务器是否已经充值0没有，1已充值
 	field :add_money, type: Integer, default: 0 

end