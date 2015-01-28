# 
class ItoolsController < AppSideController

	ITools_PEM = "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC2kcrRvxURhFijDoPpqZ/IgPlA\ngppkKrek6wSrua1zBiGTwHI2f+YCa5vC1JEiIi9uw4srS0OSCB6kY3bP2DGJagBo\nEgj/rYAGjtYJxJrEiTxVs5/GfPuQBYmU0XAtPXFzciZy446VPJLHMPnmTALmIOR5\nDddd1Zklod9IQBMjjwIDAQAB\n-----END PUBLIC KEY-----"

	def success msg
    Rails.logger.debug msg if msg
    render json: 'success'
  end

  def fail msg
    Rails.logger.debug msg if msg
    render json: 'fail'
  end

	def verify_pay
		# 解签
		data = decrypt Base64.decode64(params[:notify_data])
		Rails.logger.debug "itools解签报文：#{data}"
		# 校验
		unless verify? params[:sign], data 
			Rails.logger.debug "签名验证不通过"
		end
		data = JSON.parse data
		
		payment = HashWithIndifferentAccess.new(
      order_id:           data['order_id_com'],
      platform_order_id:  data['order_id'],
      state:              true ,
      money:              data['amount'].to_i,
      params:             params.to_json
    )
    IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
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
