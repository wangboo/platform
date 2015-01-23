require 'digest/md5'

class JiyuOrder
	include Mongoid::Document
 	include Mongoid::Timestamps

 	field :role_id
 	field :product_id
 	field :server_id
 	field :platform

 	field :order_id

 	def zone_id
 		Server.find(server_id).zone_id
 	end

 	def haima_url
 		server = Server.find(server_id)
 		"http://#{server.ip}:#{server.port}/jiyu/admin/tools/haimaCharge"
 	end

 	def itools_url
 		server = Server.find(server_id)
 		"http://#{server.ip}:#{server.port}/jiyu/admin/tools/haimaCharge"
 	end

 	# 1-8 充值，9月卡
 	def validate_charge money
		@hash ||= {'1' => 10, '2' => 30, '3' => 50, '4' => 100, '5' => 200, '6' => 500, '7' => 10000, 
			'8' => 20000, '9' => 25}
		@hash[product_id] == money
	end

 	def self.prefix
 		"XY"
 	end

 	def self.private_key
 		"w231520"
 	end

 	# 创建订单号
 	def self.generate_order role_id, product_id, server_id, platform
 		date = Time.new.strftime("%Y%m%d%H%M%S")
 		Rails.logger.debug "userId = #{role_id}"
 		order_id = "#{JiyuOrder.prefix}-#{date}-#{SecureRandom.hex(2)}"
 		order_id = "#{order_id}-#{JiyuOrder.suffix(order_id)}"
 		self.generate_order(order_id, money, server_id, platform) if JiyuOrder.where(order_id: order_id).exists?
 		JiyuOrder.create(order_id: order_id, product_id: product_id, server_id: server_id, role_id: role_id)
 	end

 	def self.suffix order 
 		Digest::MD5.hexdigest(order+JiyuOrder.private_key).chars.each_with_index.reduce(""){|s,e|if e[1]%4==0 then s<<e[0] else s end}
 	end


end