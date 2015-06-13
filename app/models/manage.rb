class Manage 

	include Mongoid::Document
	include Mongoid::Timestamps
	# 用户白名单, 在维护模式下才会启用服务器IP白名单
	field :white_ips, type: Array, default: []
	# 维护提示
	field :white_ips_notice, default: "服务器正在维护中，请稍后登陆"
	# 维护模式,在维护模式下才会启用服务器IP白名单
	field :white_ips_on, type: Boolean, default: false 
	# 平台白名单
	field :white_platform, type: Array, default: []
	# 是否开启平台白名单
	field :white_platform_on, type: Boolean, default: false 
	# 维护提示
	field :white_platform_notice, default: "xxxx与6月20日10点准时开放"

end