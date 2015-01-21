require 'digest/md5'
require 'digest/sha1'

class HaimaController < AppSideController

	def verify_pay
		Rails.logger.debug "params = #{params}"
		unless valid_sign params[:transdata], params[:sign]
			# 签名验证不通过
			Rails.logger.debug "签名验证不通过"
			return render json: "FAILURE"
		end
		data = JSON.parse params[:transdata]
		# 是否是新订单
		charge_info = HaimaChargeInfo.find_or_create_by(transid: data['transid']) do |c|
			data.each{|k,v|c[k] = v}
			new_charge = true 
		end
		jiyu_order = JiyuOrder.where(order_id: data['exorderno']).first
		# 校验订单
		unless jiyu_order
			Rails.logger.debug "订单不存在"
			return render json: "FAILURE"
		end
		# 已经充值成功 或者 交易失败， 或者 是冲正交易
		if charge_info.add_money == 1 or charge_info.result == 1 or charge_info.transtype == 1
			return render json: "SUCCESS"
		end
		# 产品-钱 校验
		# unless charge_hash[jiyu_order.product_id] * 100 == data['money']
		# 	Rails.logger.debug "商品id和money不对应"
		# 	return render json: "SUCCESS"
		# end
		Rails.logger.debug "post #{jiyu_order.haima_url}"
		data['game_user_id'] = jiyu_order.role_id
		data['product_id'] = jiyu_order.product_id
		data['result'] = 'SUCCESS'
		begin
			resp = HTTParty.post(jiyu_order.haima_url, body: data).body
			if resp == 'ok'
				charge_info.add_money = 1
				charge_info.save
			else
				Rails.logger.debug "充值失败：服务器返回:#{resp}"
				return render json: "FAILURE"
			end
		rescue 
			Rails.logger.debug "充值失败：调用服务器发生错误"
			return render json: "FAILURE"
		end
		render json: "SUCCESS"
	end	

	private
	def charge_hash
		{1 => 10, 2 => 30, 3 => 50, 4 => 100, 5 => 200, 6 => 500, 7 => 10000, 8 => 20000}
	end
	def api_key
		"NEU0Qzg4OUMxNzI1NDBEN0RCODc3RDYwREM0OUQ1REUzMUI3OTA4Q09UZ3pOek0yTVRBeE9UTXpNekUwTkRZeE1Tc3hPRFF6TlRNME9UYzROVGN6TmpZd05qQTVOelEyTURZd016Z3lNRGt6TlRjMk16VTFNVGM9"
	end

	def rsa_keys
		after = Base64.decode64(api_key)
		return ["", ""] unless after.size > 40
		Base64.decode64(after[40..after.size]).split("+")
	end

	def valid_sign data, sign
		Rails.logger.debug "'#{Rails.root.join('lib','haima','demo')}' '#{api_key}' '#{data}' '#{sign}'"
		%x('#{Rails.root.join('lib','haima','demo')}' '#{api_key}' '#{data}' '#{sign}')
		Rails.logger.debug $?.to_s
		$?.to_s.match(/(\d+)$/)[1] == '0'
	end



end