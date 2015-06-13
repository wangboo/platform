require 'base64'
# 百度充值
class BaiduController < AppSideController

	def self.keys
		@keys ||= [:AppId, :Act, :ProductName, :ConsumeStreamId, :CooOrderSerial, :Uin,
			:GoodsId, :GoodsInfo, :GoodsCount, :OriginalMoney, :OrderMoney, :Note, :PayStatus,
			:CreateTime]
	end

	def self.app_key
		@app_key ||= "8395360142b469f9ef9d0236d1ec82f93f4212705af8b63b"
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
		md5_str = BaiduController.keys.map{|k|params[k]}.join << BaiduController.app_key
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
