class UcChargeInfo
	include Mongoid::Document
 	include Mongoid::Timestamps

 	field :orderId, 			type: String #订单号，anysdk产生的订单号
 	field :gameId, 				type: String
 	field :accountId, 			type: String
 	field :creator, 			type: String#
 	field :payWay, 				type: String#
 	field :amount, 				type: String#
 	field :callbackInfo, 		type: String#
 	field :orderStatus, 		type: String#
 	field :failedDesc, 			type: String#
 	field :cpOrderId,			type: String#
 	field :add_money,			type: Integer
end