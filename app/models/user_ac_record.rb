class UserAcRecord 
	include Mongoid::Document
	# 用户id
	field :user_id, 						type: BSON::ObjectId
	# 批次id
	field :active_batch_id, 		type: BSON::ObjectId
	# 激活码对应的Id
	field :active_code_id, 			type: BSON::ObjectId
	# 服务器id
	field :zone_id,							type: Integer
	# 激活码兑奖类型
	field :active_type_id,			type: BSON::ObjectId
	# 激活码
	field :code  

	index({user_id: 1, active_batch_id: 1, zone_id: 1}, {unique: true})
	index({user_id: 1, active_type_id: 1, zone_id: 1}, {unique: true})
end