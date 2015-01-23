# 百度充值
class BaiduChargeInfo
	include Mongoid::Document
 	include Mongoid::Timestamps

 	# 应用 ID,对应游戏客户端中使用的 APPID
 	field :app_id
 	# 1
 	field :act
 	# 应用名称
 	field :product_name
 	# 消费流水号
 	field :consume_stream_id
 	# 商户订单号
 	field :coo_order_serial
 	# 91账号ID
 	field :uin
 	# 商品 ID
 	field :goods_id
 	# 商品名称
 	field :goods_info
 	# 商品数量
 	field :goods_count
 	# 原始总价(格式:0.00)
 	field :original_money, 						type: Integer
 	# 实际总价(格式:0.00)
 	field :order_money,								type: Integer
 	# 即支付描述(客户端 API 参数中的 payDescription 字段) 购买时客户端应用通过 API 传入,原样返回给应用服务器 开发者可以利用该字段,定义自己的扩展数据。例如区分游戏 服务器
 	field :note
 	# 支付状态:0=失败,1=成功
 	field :pay_status
 	# 创建时间
 	field :create_time
 	# 游戏服务器是否已经充值0没有，1已充值
 	field :add_money, type: Integer, default: 0 

end