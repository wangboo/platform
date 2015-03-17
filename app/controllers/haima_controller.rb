require 'digest/md5'
require 'digest/sha1'

class HaimaController < AppSideController

	def success msg
    Rails.logger.debug msg if msg
    render json: 'SUCCESS'
  end

  def fail msg
    Rails.logger.debug msg if msg
    render json: 'FAILURE'
  end

	def verify_pay
		Rails.logger.debug "params = #{params}"
		unless valid_sign params[:transdata], params[:sign]
			# 签名验证不通过
			Rails.logger.debug "签名验证不通过"
			return render json: "FAILURE"
		end
		data = JSON.parse params[:transdata]
		payment = HashWithIndifferentAccess.new(
      order_id:           data['exorderno'],
      platform_order_id:  data['transid'],
      state:              data[	'result'] == '0',
      money:              data['money'].to_i / 100,
      params:             params.to_json
    )
    IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
	end	

	private
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
