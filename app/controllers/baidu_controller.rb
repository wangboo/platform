require 'base64'
require 'digest/md5'
# 百度充值
class BaiduController < AppSideController

	def self.keys
		@keys ||= [:AppId, :Act, :ProductName, :ConsumeStreamId, :CooOrderSerial, :Uin,
			:GoodsId, :GoodsInfo, :GoodsCount, :OriginalMoney, :OrderMoney, :Note, :PayStatus,
			:CreateTime]
	end

	def self.app_key mask 
		case mask 
		when "ANDROID-XICHU-WCBY-BAIDU"
			"f3Os4GAOqxgm79GqbnkT9L8T"
		when 'ANDROID-XICHU-BAIDU'
			"8395360142b469f9ef9d0236d1ec82f93f4212705af8b63b"
		end
	end

	def self.appid
		@appid ||= 3067515
	end

	def self.key_pairs
		@pairs ||= {
			app_id: 						:AppId,
			act: 								:Act,
			product_name: 			:ProductName,
			consume_stream_id: 	:ConsumeStreamId,
			coo_order_serial: 	:CooOrderSerial,
			uin: 								:Uin,
			goods_id: 					:GoodsId,
			goods_info: 				:GoodsInfo,
			goods_count: 				:GoodsCount,
			original_money: 		:OriginalMoney,
			order_money: 				:OrderMoney,
			note: 							:Note,
			pay_status: 				:PayStatus,
			create_time:  			:CreateTime
		}
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
		md5_str = BaiduController.keys.map{|k|params[k]}.join << BaiduController.app_key(JiyuOrder.find_by(order_id: params['CooOrderSerial']).platform_mask)
		# md5_str = ERB::Util.url_encode(md5_str)
		Rails.logger.debug "md5_str = #{md5_str}"
		Rails.logger.debug "md5 = #{Digest::MD5.hexdigest(CGI::unescape(md5_str))}"
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

	def self.login token
    	sign = Digest::MD5.hexdigest "#{BaiduController.appid}#{token}f3Os4GAOqxgm79GqbnkT9L8T"
    	host = 'querysdkapi.91.com/CpLoginStateQuery.ashx'
    	body = HTTParty.post("http://#{host}?AppID=#{BaiduController.appid}&AccessToken=#{token}&Sign=#{sign}").body
    	md5_str = "#{BaiduController.appid}#{body['ResultCode']}#{Base64.decode64 body['Content']}f3Os4GAOqxgm79GqbnkT9L8T"
    	Rails.logger.debug "body====#{body}"
    	unless body['Sign'] == Digest::MD5.hexdigest(md5_str)
			Rails.logger.debug "签名校验失败"
			return fail
		end
    	resp
	end

		# ANDROID_BAIDU支付接口
	def android_verify_pay
		keys = []
		md5_str = BaiduController.keys.map{|k|params[k]}.join << BaiduController.app_key(JiyuOrder.find_by(order_id: params['CooOrderSerial']).platform_mask)
		# md5_str = ERB::Util.url_encode(md5_str)
		Rails.logger.debug "md5_str = #{md5_str}"
		Rails.logger.debug "md5 = #{Digest::MD5.hexdigest(CGI::unescape(md5_str))}"
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
