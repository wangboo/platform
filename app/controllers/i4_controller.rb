# i4支付
class I4Controller < AppController

	I4_PEM = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA29hYrlTLzXGX284Yu5lw\nc09k8iNpNYBvbFoQfGOrYRgD3l1+nZtX1qPtKHwVVFG2UKih9cQT8gc/BsCzkxIO\nnSHP4wtI8m4kttbs+b+DGstZnQLgRoTa+zzGJWhDSY5Gngg2xXfh7Ewx1SPdLoiP\nfaFKj8/MNjGfZz1iI3wmWMLDJftFc6drd42LBT63Qoph9dBZZlnxgINWiGHGpeZC\nGoxalcYyt+gH+h+w5Og2+lsvrH4IWSzk6eRSt8qi8rDK9lJOw0rHtqhpbAgaAs3k\nfDml1yFlzT3XrP5FvLo09wigg/q/8egcssXCdFuO//42jPaCk0H9HpZrmjQFK8Au\nXQIDAQAB\n-----END PUBLIC KEY-----"

	def success msg
    Rails.logger.debug msg if msg
    render json: 'success'
  end

  def fail msg
    Rails.logger.debug msg if msg
    render json: 'fail'
  end

	# 支付
	def verify_pay
		# 解签
		data = params.permit(:order_id, :billno, :account, :status, :app_id, :role, :zone, :amount)
		#return fail("签名验证不通过") unless verify? params[:sign], data

		payment = HashWithIndifferentAccess.new(
      order_id:           data['billno'],
      platform_order_id:  data['order_id'],
      state:              data['status'].to_i == 0,
      money:              data['amount'].to_i,
      params:             params.to_json
    )
    IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
	end

	# 校验
	def verify? sign, data
		data_str = data.map{|a|a.join("=")}.sort.join("&")
		sign_str = Base64.decode64 params[:sign]
    logger.debug "sign = #{sign}"
		 Rails.logger.debug "java -jar '#{Rails.root.join("lib", "i4_decrypt", "i4_decrypt.jar")}' '#{sign}' '#{data_str}'"
		%x(java -jar '#{Rails.root.join("lib", "i4_decrypt", "i4_decrypt.jar")}' '#{sign}' '#{data_str}')
		 Rails.logger.debug "verify? #{$?}"
		$?.to_s.match(/(\d+)$/)[1] == '0'
		# false
	end
end
