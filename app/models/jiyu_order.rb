require 'digest/md5'

class JiyuOrder
	include Mongoid::Document
 	include Mongoid::Timestamps

 	field :role_id
 	field :product_id
 	field :server_id
 	field :platform

 	field :order_id

 	def server
 		Server.find(server_id)
 	end

 	def zone_id
 		server.zone_id
 	end

 	def ios_url
 		"http://#{server.ip}:#{server.port}/jiyu/admin/tools/iosCharge"
 	end

 	def platform_mask
		server.platform.mask
	end

 	# 1-8 充值，9月卡
 	def validate_charge money
 		JiyuOrder.product_money_mapping[self.product_id] == money
	end

	def self.product_money_mapping
		@gmm ||= {'1' => 6, '2' => 30, '3' => 50, '4' => 100, '5' => 200, '6' => 500, '7' => 1000,
			'8' => 2000, '9' => 25, '10'=>10, '11'=>28, '12'=>98}
	end

	def self.gold_product_mapping
		@gpm ||= {60=>'1', 300=>'2', 500=>'3', 1000=>'4', 2000=>'5', 5000=>'6', 10000=>'7', 20000=>'8', 250=>'9',
			250=>'10', 750=>'11', 2800=>'12'}
	end

	def self.gold2product gold
		gold_product_mapping[gold] or '-1'
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
 		# Rails.logger.debug "userId = #{role_id}"
 		order_id = "#{JiyuOrder.prefix}#{date}#{SecureRandom.hex(2)}"
 		order_id = "#{order_id}#{JiyuOrder.suffix(order_id)}"
 		self.generate_order(order_id, money, server_id, platform) if JiyuOrder.where(order_id: order_id).exists?
 		JiyuOrder.create(order_id: order_id, product_id: product_id, server_id: server_id, role_id: role_id)
 	end

 	def self.suffix order
 		Digest::MD5.hexdigest(order+JiyuOrder.private_key).chars.each_with_index.reduce(""){|s,e|if e[1]%4==0 then s<<e[0] else s end}
 	end


end
