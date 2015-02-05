class GbChargeInfo
	include Mongoid::Document
	include Mongoid::Timestamps

	field :OrderId, 				type: String #订单号，anysdk产生的订单号
	field :GameId, 					type: String#
	field :ServerId, 				type: String#
	field :Uid, 					type: String#
	field :Amount, 					type: Integer#
	field :Gold, 					type: String#
	field :CallbackInfo, 			type: String#
	field :OrderStatus, 			type: String#
	field :Time, 					type: String#	
	field :AddMoney,				type: String#游戏服务器是否已经充值0没有，1已充值

end