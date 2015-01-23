# Itools 充值订单
class ItoolsChargeInfo
	include Mongoid::Document
 	include Mongoid::Timestamps

 	# 发起支付时的订单号即商户订单号
 	field :order_id_com
 	# 支付的用户 id
 	field :user_id
 	#成功支付的金额 
 	field :amount
 	# 支付帐号
 	field :account
 	# 支付平台的订单号
 	field :order_id
 	# 支付结果, 目前只有成功状态, success
 	field :result

 	# 游戏服务器是否已经充值0没有，1已充值
 	field :add_money, type: Integer, default: 0 

end