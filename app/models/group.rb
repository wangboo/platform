# 平台分组
class Group 
	include Mongoid::Document
	include Mongoid::Timestamps

	# 组名
	field :name 
	# 平台集合
	field :platform_ids, type: Array, default: []

	def platforms
		Platform.find(platform_ids)
	end


end