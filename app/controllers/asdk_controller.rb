
class AsdkController < AppSideController

	def success msg
    Rails.logger.debug msg if msg
    render json: 'success'
  end

  def fail msg
    Rails.logger.debug msg if msg
    render json: 'failure'
  end

	def app_key
		"e8cdc1edf50989a6"
	end

	def keys
		%w(account money addtime orderid customorderid paytype senddate custominfo success).sort
	end

	def verify_pay
		md5_before = keys.map{|k|"#{k}=#{params[k]}"}.join("&") << app_key
		md5 = Digest::MD5.hexdigest md5_before
		unless md5 == params[:sign]
			# 签名验证不通过
			Rails.logger.debug "签名验证不通过"
			return render json: "FAILURE"
		end
		payment = HashWithIndifferentAccess.new(
      order_id:           params['customorderid'],
      platform_order_id:  params['orderid'],
      state:              params[	'success'] == '1',
      money:              params['money'].to_i / 100,
      params:             params.to_json
    )
    IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
	end


end
