# 账号表
class Account
	include Mongoid::Document
	# 自增主键
	field :aid, type: Integer, default: ->{AutoKey.next_id "account", "id"}
	field :channel_id, 	type: Integer
	field :channel_name
	field :platform,		type: Integer
	field :vers
	field :account_id
	field :create_time, type: Time, default: ->{Time.now}
	field :first_time, 	type: Time, default: ->{Time.now}
	field :last_time, 	type: Time
	field :mac
	field :ip
	field :device
	field :version

	# 平台+account_id 唯一
	index({ account_id: 1, channel_id: 1 }, { unique: true })

end