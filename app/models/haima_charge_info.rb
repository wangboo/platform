class HaimaChargeInfo
	include Mongoid::Document
 	include Mongoid::Timestamps

 	field :appid						#商户在支付平台的应用代码
 	field :exorderno				#应用平台的交易订单号
 	field :sign							#请求消息签名
 	field :transid					#计费支付平台的交易流水号
 	field :waresid					#平台为应用内需计费商品分配的编码

 	field :feetype					#计费类型：0–消费型_应用传入价格
 	field :money						#本次交易的金额，单位：分
 	field :count						#本次购买的商品数量
 	field :result						#交易结果：0–交易成功；1–交易失败
 	field :transtype				#交易类型：0–交易；1–冲正
 	field :transtime				#transtime yyyy-mm-dd hh24:mi:ss
 	field :cpprivate				#商户私有信息
 	field :paytype					#支付方式（该字段值后续可能会增加）0 –话费支付,1 - 充值卡, 2 –游戏点卡,3 –银行卡,401 –支付宝,402 –财付通,5 –爱贝币,6 一键支付
 	# 游戏服务器是否已经充值0没有，1已充值
 	field :add_money, type: Integer, default: 0 

end 	