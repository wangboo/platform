class XyController < AppSideController
  
  def fail msg=nil
    Rails.logger.debug msg if msg
    render json: 'fail'
  end

  def success msg=nil
    Rails.logger.debug msg if msg
    render json: 'success'
  end

  def app_key
    "7MN4iNzfm22ZyIOYTJwi9Sqbxhhz4AZI"
  end
  
  def pay_key
    "0wSSJrEIu7IQksbELhVo6wuRyCfzHljz"
  end

  def key_sorts
    [:amount, :extra, :orderid, :serverid, :ts, :uid]
  end

  def verify_pay
    before = key_sorts.map{|k|"#{k}=#{params[k]}"}.join("&")
    app_sign = Digest::MD5.hexdigest("#{app_key}#{before}")
    pay_sign = Digest::MD5.hexdigest("#{pay_key}#{before}")
    unless app_sign == params[:sign] and pay_sign == params[:sig]
      Rails.logger.debug "校验签名不过"
      return fail
    end
    order_id = params[:extra].match(/orderNo=(.*)$/)[1]
    payment = HashWithIndifferentAccess.new(
      order_id:           order_id,
      platform_order_id:  params['orderid'],
      state:              true,
      money:              params['amount'].to_i,
      params:             params.to_json
    )
    IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
  end


end
