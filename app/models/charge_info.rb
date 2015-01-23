class ChargeInfo
	include Mongoid::Document
 	include Mongoid::Timestamps

 	field :order_id, 				type: String #订单号，anysdk产生的订单号
 	field :product_count, 	type: String#要购买商品数量（暂不提供具体数量）
 	field :amount, 					type: String#支付金额，单位元 值根据不同渠道的要求可能为浮点类型
 	field :pay_status, 			type: String#支付状态，1为成功
 	field :pay_time, 				type: String#支付时间，YYYY-mm-dd HH:ii:ss格式
 	field :user_id, 				type: String#用户id，用户系统的用户id
 	field :order_type, 			type: String#支付方式，详见支付渠道标识表
 	field :game_user_id, 		type: String#游戏内用户id,支付时传入的Role_Id参数
 	field :server_id, 			type: String#服务器id，支付时传入的server_id 参数
 	field :product_name, 		type: String#商品名称，支付时传入的product_name 参数
 	field :product_id, 			type: String#商品id,支付时传入的product_id 参数
 	field :private_data, 		type: String#自定义参数，调用客户端支付函数时传入的EXT参数，透传给游戏服务器
 	field :channel_number, 	type: String#渠道编号
 	field :sign, 						type: String#签名串，验签参考签名算法
 	field :source, 					type: String#渠道服务器通知 AnySDK 时请求的参数
 	field :add_money,				type: Integer#游戏服务器是否已经充值0没有，1已充值
 	
end