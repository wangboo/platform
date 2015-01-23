# 
class ItoolsController < AppSideController

	ITools_PEM = "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC2kcrRvxURhFijDoPpqZ/IgPlA\ngppkKrek6wSrua1zBiGTwHI2f+YCa5vC1JEiIi9uw4srS0OSCB6kY3bP2DGJagBo\nEgj/rYAGjtYJxJrEiTxVs5/GfPuQBYmU0XAtPXFzciZy446VPJLHMPnmTALmIOR5\nDddd1Zklod9IQBMjjwIDAQAB\n-----END PUBLIC KEY-----"

	def verify_pay
		# 解签
		data = decrypt Base64.decode64(params[:notify_data])
		Rails.logger.debug "itools解签报文：#{data}"
		# 校验
		unless verify? params[:sign], data 
			Rails.logger.debug "签名验证不通过"
		end
		data = JSON.parse data
		# 查找订单
		jiyu_order = JiyuOrder.where(order_id: data['order_id_com']).first
		unless jiyu_order
			Rails.logger.debug "找不到订单 #{data['order_id_com']}"
			return render json: "FAILURE" 
		end
		data['amount'] = data['amount'].to_i
		# 校验产品
		# unless jiyu_order.validate_charge data['amount']
		# 	Rails.logger.debug "产品id校验不通过"
		# 	return render json: "FAILURE" 
		# end 
		# 存储订单
		charge_info = ItoolsChargeInfo.find_or_create_by(order_id_com: data['order_id_com']) do |i|
			data.each{|k,v|i[k] = v}
		end
		# 校验订单result
		unless charge_info.result == 'success'
			Rails.logger.debug "是失败状态"
			return render json: "FAILURE" 
		end
		# 订单判重充值成功
		return render json: "FAILURE" if charge_info.add_money == 1
		Rails.logger.debug "itools_url = #{jiyu_order.itools_url}"
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

	def decrypt data
		pkey = OpenSSL::PKey::RSA.new(ITools_PEM)
		digest = OpenSSL::Digest::SHA1.new
		bytes = data.bytes
		len = bytes.size
		Rails.logger.debug "len = #{len}"
		from, to = 0, 128
		rst = ""
		while from < len 
			rst << pkey.public_decrypt(bytes[from...to].pack("C*"))
			from = to 
			to = to + 128 
		end
		rst 
	end

	def verify? sign, to_sign
		pkey = OpenSSL::PKey::RSA.new(ITools_PEM)
    digest = OpenSSL::Digest::SHA1.new
    pkey.verify(digest, Base64.decode64(sign), to_sign)
	end

end