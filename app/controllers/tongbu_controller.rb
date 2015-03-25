class TongbuController < AppSideController

  def self.app_id
   @app_id ||= "1412123"
  end

  def self.app_key
    @app_key = "XF8SH3rB5lby#VLivF8He3r5Olyn#ViX"
  end

  def self.login sid
    code = HTTParty.get("http://tgi.tongbu.com/check.aspx?k=#{sid}").body
    logger.debug "req = http://tgi.tongbu.com/check.aspx?k=#{sid} code = #{code}"
    case code
    when '1'
      logger.debug "登陆有效"
    when '0'
      logger.debug "登陆失效"
    when '-1'
      logger.debug "格式错误"
    end
    code == '1'
  end

  def self.md5_keys
  @list ||= [:source, :trade_no, :amount, :partner, :paydes, :debug, :tborder]
  end

  def fail msg=nil
    logger.debug "fail = #{msg}" if msg
    render json: {status: "fail"}
  end

  def success msg=nil
    logger.debug "success = #{msg}" if msg
    render json: {status: "success"}
  end

  def verify_pay
    md5_str = self.class.md5_keys.map{|k|"#{k}=#{params[k]}"}.join("&") << "&key=" <<self.class.app_key
    md5 = Digest::MD5.hexdigest(md5_str)
    logger.debug "md5_str = #{md5_str}, str = #{md5}"
    return fail unless md5 == params[:sign]
    payment = HashWithIndifferentAccess.new(
      order_id:           params[:trade_no],
      platform_order_id:  params[:tborder],
      state:              true,
      money:              params[:amount].to_i/100,
      params:             params.to_json
    )
    IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
  end

end
