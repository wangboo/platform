
class ErrorLog

	include Mongoid::Document
	include Mongoid::Timestamps
	# 用户名
	field :username
	# 异常信息
	field :error
	# 是否处理过
	field :handled, type: Boolean, default: false

	# 所属服务器
	belongs_to :server

	attr_accessor :same_num

end