require 'base64'
# 百度充值
class BaiduController < AppSideController

	def self.keys
		@keys ||= [:AppId, :Act, :ProductName, :ConsumeStreamId, :CooOrderSerial, :Uin, 
			:GoodsId, :GoodsInfo, :GoodsCount, :OriginalMoney, :OrderMoney, :Note, :PayStatus, 
			:CreateTime]
	end

	def self.app_key
		@app_key ||= "d7f85918aaed84a4ae1e82bb56414519e0944eb1368b8867"
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

	def fail
		render json: '{"ErrorCode":"0","ErrorDesc":"接收失败"}'
	end

	def success
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
		data = BaiduController.key_pairs.reduce({}){|s,p|s[p[0]]=params[p[1]];s}
		# 查找订单
		jiyu_order = JiyuOrder.where(order_id: data[:coo_order_serial]).first
		unless jiyu_order
			Rails.logger.debug "找不到订单 #{data[:coo_order_serial]}"
			return fail
		end
		data[:order_money] = data[:order_money].to_i
		data[:original_money] = data[:original_money].to_i
		# 校验产品
		# unless jiyu_order.validate_charge data['order_money']
		# 	Rails.logger.debug "产品id校验不通过"
		# 	return render json: "FAILURE" 
		# end 
		# 存储订单
		charge_info = BaiduChargeInfo.find_or_create_by(coo_order_serial: data[:coo_order_serial]) do |i|
			BaiduController.key_pairs.keys.each{|k|i[k] = data[k]}
		end
		# 校验订单result
		unless charge_info.pay_status == '1'
			Rails.logger.debug "是失败状态"
			return fail
		end
		# 订单判重充值成功
		return fail if charge_info.add_money == 1
		# Rails.logger.debug "itools_url = #{jiyu_order.itools_url}"
		data['game_user_id'] = jiyu_order.role_id
		data['product_id'] = jiyu_order.product_id
		data['exorderno'] = jiyu_order.order_id
		data['money'] = data[:order_money]
		data['transtime'] = Time.now
		data['result'] = 'SUCCESS'
		begin 
			resp = HTTParty.post(jiyu_order.itools_url, body: data).body
			if resp == 'ok'
				charge_info.add_money = 1
				charge_info.save 
			else 
				Rails.logger.debug "游戏服务器充值失败"
				return fail
			end
		rescue
			Rails.logger.debug "游戏服务器充值失败"
			return fail
		end
		success
	end

end