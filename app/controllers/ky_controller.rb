require 'digest/md5'

class KyController < AppSideController

  KY_PEM = "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDYQCiFb4j6HXzJn80wvWKmFERH\nDWvw463rUKiX9vVCRgYBuzZ9vtIKSsz1yfwP9lT+s4fKkzKZa6kQQ6UK62iPCu07\naR2Rsd6AV0OhhjKi6zMpfWFgQrlI/fAUQGQTQ73KlCDNysIKzZzJcnilpDwrzmlu\n4jdUW3a3ZZ6Ou0bI2QIDAQAB\n-----END PUBLIC KEY-----"

  def self.app_key
    @app_key ||= 'b2bd94eb0dc9ea2be3261d1ff8db5d16'
  end

  def self.login_url
    # 42.62.21.147 f_signin.bppstore.com
    @login_url = 'http://42.62.21.147/loginCheck.php'
  end

  def self.login token
    md5 = Digest::MD5.hexdigest "#{KyController.app_key}#{token}"
    HTTParty.post(KyController.login_url, body: {tokenKey: token, sign: md5}).body
  end

  def success msg
    Rails.logger.debug msg if msg
    render json: 'success'
  end

  def fail msg
    Rails.logger.debug msg if msg
    render json: 'fail'
  end

  def entrypt
    data = Base64.decode64 params[:notify_data]
    OpenSSL::PKey::RSA.new(KY_PEM).public_decrypt data
    # logger.debug "str = #{str}"
  end

  def verify_pay
    data = entrypt.split("&").reduce({}){|s,a|k,v=a.split("=");s[k]=v;s}
    return fail "签名校验失败" unless params[:dealseq] == data['dealseq']
    # 校验订单状态
    payment = HashWithIndifferentAccess.new(
      order_id:           data['dealseq'],
      platform_order_id:  data['order_id'],
      state:              data['payresult'].to_i == 0,
      money:              data['fee'].to_i,
      params:             params.to_json
    )
    IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
  end


end
