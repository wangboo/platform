# i4支付
class I4Controller < AppController

	# 支付
	def verify_pay
		# 解签
		data = params.permit(:order_id, :billno, :account, :status, :app_id, :role, :zone, :amount)
		unless verify? params[:sign], data
			Rails.logger.debug "签名验证不通过" 
			return render json: "FAILURE" 
		end
		
		# 查找订单
		jiyu_order = JiyuOrder.where(order_id: data['billno']).first
		unless jiyu_order
			Rails.logger.debug "找不到订单 #{data['billno']}"
			return render json: "FAILURE" 
		end
		data['amount'] = data['amount'].to_i
		# 校验产品
		# unless jiyu_order.validate_charge data['amount']
		# 	Rails.logger.debug "产品id校验不通过"
		# 	return render json: "FAILURE" 
		# end 
		# 存储订单
		data[:status] = data[:status].to_i
		charge_info = I4ChargeInfo.find_or_create_by(billno: data['billno']) do |i|
			data.each{|k,v|i[k] = v}
		end
		# 校验重复订单
		if charge_info.status != 0 or charge_info.add_money == 1
			Rails.logger.debug "订单重复"
			return render json: "FAILURE" 
		end
		# 调用游戏服务器
		# Rails.logger.debug "itools_url = #{jiyu_order.itools_url}"
		data['game_user_id'] = jiyu_order.role_id
		data['product_id'] = jiyu_order.product_id
		data['exorderno'] = jiyu_order.order_id
		data['money'] = data['amount']
		data['transtime'] = Time.now
		data['result'] = 'SUCCESS'
		begin 
			resp = HTTParty.post(jiyu_order.itools_url, body: data).body
			if resp == 'ok'
				charge_info.add_money = 1
				charge_info.save 
			else 
				Rails.logger.debug "游戏服务器充值失败"
				return render json: "FAILURE" 
			end
		rescue
			Rails.logger.debug "游戏服务器充值失败"
			return render json: "FAILURE" 
		end
		render json: "SUCCESS"
	end

	# 校验
	def verify? sign, data
		data_str = data.map{|a|a.join("=")}.join("&")
		# Rails.logger.debug "java -jar '#{Rails.root.join("lib", "i4_decrypt", "i4_decrypt.jar")}' '#{sign}' '#{data_str}'"
		%x(java -jar '#{Rails.root.join("lib", "i4_decrypt", "i4_decrypt.jar")}' '#{sign}' '#{data_str}')
		# Rails.logger.debug "verify? #{$?}"
		$?.to_s.match(/(\d+)$/)[1] == '0'
	end
end