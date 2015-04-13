class TtController < AppSideController

  def self.md5_key
    @md5_key ||= "b4cf11a169b7b2a4fc820c5b70732a98"
  end

  def self.des_key
    @des_key ||= md5_key[8,8]
  end

  def self.exclude_args
    @exclude_args ||= ['action','controller','sign']
  end

  def self.undes_keys
    @undes_keys ||= ['service_version', 'input_charset', 'status']
  end

  def success msg=nil
    render text: "success"
  end

  def fail msg=nil
    Rails.logger.debug "TtController fail #{msg}"
    render text: "fail"
  end

  def decode(str)
    des_key = '16edbba3'
    str = Base64.decode64(str)
    des = OpenSSL::Cipher::Cipher.new("DES-ECB")
    des.decrypt
    des.key = self.class.des_key
    result = des.update(str)
    result << des.final
  end

  def verify_pay
    data = params.to_a.delete_if{|k,v|self.class.exclude_args.include?(k.to_s) or v.empty?}.map{|p|unless self.class.undes_keys.include? p[0].to_s then p[1] = decode p[1] end;p}.to_h
    before = data.sort{|a,b|a[0]<=>b[0]}.map{|i|i.join("=")}.join("&") << "&key=#{self.class.md5_key}"
    #Rails.logger.debug "before = #{before}"
    after = Digest::MD5.hexdigest(before).upcase
   # Rails.logger.debug "after = #{after}, sign = #{params[:sign]}"
    return fail("验签错误") unless after == params[:sign]
    payment = HashWithIndifferentAccess.new(
      order_id:           data['out_trade_no'],
      platform_order_id:  data['transaction_id'],
      state:              data['trade_status'].to_i == 2,
      money:              data['total_fee'].to_i/100,
      params:             data.to_json
    )
    IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
  end


end
