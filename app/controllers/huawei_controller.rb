require 'base64'
require 'digest/md5'
class HuaweiController < AppController

	def self.app_id
		1000019559
	end

	def self.keys
		@keys ||= [:AppId, :Act, :ProductName, :ConsumeStreamId, :CooOrderSerial, :Uin,
			:GoodsId, :GoodsInfo, :GoodsCount, :OriginalMoney, :OrderMoney, :Note, :PayStatus,
			:CreateTime]
	end

	def self.login token, user_in
		begin 
	    	user = QicUser.find_or_create_by(username: user_in) do |u|
		      	u.username = account_id
		      	u.password = ""
	    	end
    	return [user, account_id]
		rescue => e
			Rails.logger.error "login to mud error #{e}"
			return [-1, 0]
		end

	end

	def pay_key
		"c0e24702a24d4c48b3ca4c0646138bff"
	end

	def fail msg=nil
		Rails.logger.debug msg if msg
		render json: '{"ErrorCode":"0","ErrorDesc":"接收失败"}'
	end

	def success msg=nil
		Rails.logger.debug msg if msg
		render json: '{"ErrorCode":"1","ErrorDesc":"接收成功"}'
	end

	# 支付接口
	def verify_pay
		md5_str = HuaweiController.keys.map{|k|params[k]}.join << pay_key
		# md5_str = ERB::Util.url_encode(md5_str)
		Rails.logger.debug "md5_str = #{md5_str}"
		Rails.logger.debug "md5 = #{Digest::MD5.hexdigest(CGI::unescape(md5_str))}"
		Rails.logger.debug "#{params[:Sign]}"
		unless params[:Sign] == Digest::MD5.hexdigest(CGI::unescape(md5_str))
			Rails.logger.debug "签名校验失败"
			return fail
		end
		payment = HashWithIndifferentAccess.new(
	      order_id:           params['CooOrderSerial'],
	      platform_order_id:  params['ConsumeStreamId'],
	      state:              params['PayStatus'].to_i == 1,
	      money:              params['OrderMoney'].to_i,
	      params:             params.to_json
    	)
   		IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
	end

end
