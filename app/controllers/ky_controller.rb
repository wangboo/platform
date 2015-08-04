require 'digest/md5'

class KyController < AppSideController

  KY_PEM = "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDAw/iiqHBRdg25+yKyNxcbS70K\nBqzrXz6X2K+T7G0gTPvzam4exgE7mnfPBIZAB1qQQQGg7NfKJY7Vpe7rdlvmUagp\nuWKPVRLb5wHB71bQhgNc9iAV3Fn/SpdFospDV+/aA+gvIoAqe7mpe3so6C5HwDKQ\njKiBVP38NhzGB4b5uQIDAQAB\n-----END PUBLIC KEY-----"

  def self.app_key
    # @app_key ||= 'e7JTQqh43HDQH5hwYj7wPNrPG4tLjmZx'
    @app_key ||= '9a62e8372b691ae1ca746bc51411d8f9'
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
