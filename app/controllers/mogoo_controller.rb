
class MogooController < AppSideController 

	def self.secret_key
		"mogoo-3P60EINppHnQQ2MPCz"
	end

	def success msg=nil
    render json: {error_code: "0", error_message: ""}
  end

  def fail msg=nil
    Rails.logger.debug "TtController fail #{msg}"
    render json: {error_code: "1", error_message: "msg"}
  end

  def verify_keys
  	%w{uid sid oid gold time}
  end

	def verify_pay
		md5_be = verify_keys.map{|k|params[k]}.join("-") << "-" << self.secret_key
    after = Digest::MD5.hexdigest(md5_be).upcase
   # Rails.logger.debug "after = #{after}, sign = #{params[:sign]}"
    return fail("验签错误") unless after == params[:sign]
    payment = HashWithIndifferentAccess.new(
      order_id:           data['eif'],
      platform_order_id:  data['oid'],
      state:              true,
      money:              data['gold'],
      params:             data.to_json
    )
    IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
	end



end