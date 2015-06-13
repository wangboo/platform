class IiappleController < AppSideController

  def sercet_key
    'cf06b64b9b52add233ba18439b917575'
  end

  def sign_keys
    %w{transaction payType userId serverNo amount cardPoint gameUserId  transactionTime gameExtend platform status currency}.sort
  end

  def success msg=nil
    loger.debug msg if msg
    render json: {status: 0, transID0: params[:transaction]}
  end

  def fail msg=nil
    logger.error msg if msg
    render json: {status: 1, transID0: params[:transaction]}
  end

  def verify_pay
    return fail "订单状态为失败：#{params}" unless params[:status].to_i == 1
    md5be = sign_keys.map{|k|"#{k}=#{params[k]}"}.join("&")
    md5mid = Digest::MD5.hexdigest(md5be)
    md5 = Digest::MD5.hexdigest "#{md5mid}#{sercet_key}"
    return fail "校验签名失败" unless md5 == params[:_sign]
    data = HashWithIndifferentAccess.new(
      order_id: params[:gameExtend],
      platform_order_id: params[:transaction],
      state: true,
      money: params[:amount].to_i,
      params: params.to_json
    )
    IOSChargeInfo.charge data, proc{|m|success m}, proc{|m|fail m}
  end


end
