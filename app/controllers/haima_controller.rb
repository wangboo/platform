require 'digest/md5'
require 'digest/sha1'

class HaimaController < AppSideController

	def success msg=nil
    Rails.logger.debug msg if msg
    render json: 'SUCCESS'
  end

  def fail msg=nil
    Rails.logger.debug msg if msg
    render json: 'FAILURE'
  end

	def verify_pay
		return fail unless verify2
		payment = HashWithIndifferentAccess.new(
      order_id:           params['out_trade_no'],
      platform_order_id:  '0',
      state:              params[	'trade_status'].to_i == 1,
      money:              params['total_fee'].to_i,
      params:             params.to_json
    )
    IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
	end

	private
	def api_key
	  "87ba22ff54016a5cbb7602a00b5ff013"
  end

  def verify2
    md5_before = %w(notify_time appid out_trade_no total_fee subject body trade_status).map{|k|"#{k}=#{CGI.escape params[k]}"}.join("&") << api_key
    #escape = CGI.escape(md5_before)
    sign = Digest::MD5.hexdigest(md5_before)
    unless params[:sign] == sign
      logger.error "校验签名错误 md5_before=#{md5_before}， sign=#{sign}, param_sign=#{params[:sign]}"
      logger.error "params = #{params}"
      return false
    end
    return true
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
