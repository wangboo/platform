require 'digest/md5'
require 'json'

class AnyPay
  def self.sort_params params
    md5_str = ""
    params.keys.sort.each do |key|
      if key != "sign"
        if params[key]
          md5_str += params[key].to_s
        end
      end
    end
    return md5_str
  end

  def self.key mask
    case mask
    when /XYGL/ then "4DB5C14BDDCEEC9610D8DB09EB51B813"
    when /BIEJI/ then "43852A705E7B0A7C19938A2168029B68"
    when /CHZB/ then "C971D5DF15A4D4BD177627E201BEB3F7"
    when /XUNQIN/ then "7C361B572BF66DBDFB7D67AE1DCDB524"
    when /YAOJI/ then "05FDF251DB1862163B304608E2A35EF4"
    else "371BB654EBE0C7E0165B0DC840F5A97C"
    end
  end

  def self.md5_digest private_key,md5_str
    md5 = Digest::MD5.hexdigest md5_str
    re_md5= Digest::MD5.hexdigest(md5+private_key)
    return re_md5
  end

  def self.verify_sign params
    if params["pay_status"].to_s != "1"
      return "ok"
    end
    sign, user_id, amount ,server_id= params["sign"], params["user_id"], params["amount"],params["server_id"]
    keys = [:order_id,:product_count,:amount,:pay_status,:pay_time,:user_id,:order_type,:game_user_id,:server_id,:product_name,:product_id,:private_data,:channel_number,:sign,:source, :enhanced_sign]
    exclude = ['action', 'controller', 'sign']
    data = params.delete_if{|k,v|exclude.include? k}
    md5_str = data.to_a.sort{|v0,v1|v0[0]<=>v1[0]}.collect{|v|v[1]}.join

    private_key = AnyPay.key params[:private_data]
    Rails.logger.debug("md5_str = #{md5_str}")
    #md5_str = sort_params params
    md5 = md5_digest private_key,md5_str
# <<<<<<< Updated upstream
    #保存anysdk传过来的参数信息
    data = keys.reduce({}){|s,a|s[a]=params[a];s}

    product_id = params['product_id']
    list = [6,30,50,100,200,500,1000,2000,25,12,25,98]
    if amount.to_i != list[product_id.to_i-1]
        data['add_money']=0
        ChargeInfo.create data
        return "ok"
    end

    Rails.logger.debug "sign=#{sign}"
    Rails.logger.debug "md5=#{md5}"
    charge_info = ChargeInfo.find_by order_id:params["order_id"]
    # data["result"] = "SUCCESS"
    if !charge_info
      if sign == md5
        #调游戏后台服务器
        data["result"] = "SUCCESS"
        infos = {headers: {'content-type'=>'application/json; charset=utf-8'}, query: data}
        uri = "http://#{server_id}/jiyu/admin/tools/anysdk"
        resp = HTTParty.post("http://#{params[:server_id]}/jiyu/admin/tools/anysdk", infos)
        Rails.logger.debug("game 1111 server resp = #{resp}")
        if resp.to_s=="ok"
          data['add_money']=1
        else
          data['add_money']=0
        end
        data.delete("result")
        ChargeInfo.create data
        if resp.to_s == "ok"
           return "ok"
        else
            return "fail"
        end
      else
        return "fail"
      end
    elsif charge_info.add_money == 0
        if sign == md5
          #调游戏后台服务器
          data['result']="SUCCESS"
          infos = {headers: {'content-type'=>'application/json; charset=utf-8'}, query: data}
          uri = "http://#{server_id}/jiyu/admin/tools/anysdk"
          resp = HTTParty.post("http://#{params[:server_id]}/jiyu/admin/tools/anysdk", infos)
          Rails.logger.debug("game 22222 server resp = #{resp},resp.class=#{resp.class}")
          data.delete("result")
          if resp.to_s=="ok"
            charge_info.add_money = 1
            charge_info.save
            return "ok"
          end
          return "fail"
        else
         return "fail"
        end
    else
      return "ok"
    end
  end

  # def self.uc_verify_pay params
  #   Rails.logger.debug "prams = #{params}"
  #   # body= params['body']
  #   hash_data = params['data']
  #   hash_data = JSON.parse(params['data']) if params['data'].is_a?(String)
  #   hash_data = hash_data.to_h
  #   params['data'] = hash_data
  #   if hash_data["orderStatus"].to_s != "S"
  #     Rails.logger.debug "订单状态不合法 #{hash_data["orderStatus"]}"
  #     return "SUCCESS"
  #   end
  #   sign = params['sign']
  #   amount = hash_data['amount']
  #   product_id = params["data"]["callbackInfo"].match(/ProductId=(.*)$/)[1]
  #   list = [6,30,50,100,200,500,1000,2000,25]
  #   if amount.to_i != list[product_id.to_i-1]
  #       hash_data['add_money']=0
  #       hash_data.delete("controller")
  #       hash_data.delete("action")
  #       #hash_data.permit!
  #       UcChargeInfo.create hash_data
  #       Rails.logger.debug "金钱不合法 #{}"
  #       return "SUCCESS"
  #   end

  #   Rails.logger.debug "hash_data111 = #{hash_data}"
  #     #hash_data={a=>b,c=>d}
  #   md5_str = ""
  #   hash_data.keys.sort.each do |key|
  #      value = hash_data[key]
  #      md5_str +=(key+"=#{hash_data[key]}")
  #   end
  #   Rails.logger.debug "md5_str=#{md5_str}"
  #   private_key = "a6fb07456626474f9ed441b455dc9922"
  #   md5 = Digest::MD5.hexdigest (md5_str+private_key)
  #   #sign = md5 = 0
  #   charge_info = UcChargeInfo.find_by orderId:hash_data["orderId"]
  #   server_id=params["data"]["callbackInfo"].match(/serverId=(.*)$/)[1]
  #   Rails.logger.debug "server_id = #{server_id}"
  #     if !charge_info
  #       if sign == md5
  #         hash_data['result']="SUCCESS"
  #         infos = {headers: {'content-type'=>'application/json; charset=utf-8'}, query: hash_data}
  #         resp = HTTParty.post("http://#{server_id}/jiyu/admin/tools/ucsdk", infos)
  #         if resp.to_s=="ok"
  #           # UcChargeInfo.create
  #           hash_data['add_money']=1
  #         else
  #           hash_data['add_money']=0
  #         end
  #         hash_data.delete("result")
  #         hash_data.delete("controller")
  #         hash_data.delete("action")
  #         Rails.logger.debug "hash_data2222=#{hash_data}"
  #         #hash_data.permit!
  #         UcChargeInfo.create hash_data
  #         if resp.to_s == "ok"
  #            return "SUCCESS"
  #         else
  #            return "fail"
  #         end
  #       else
  #         "fail"
  #       end
  #     elsif charge_info.add_money == 0
  #       if sign == md5
  #         hash_data['result']="SUCCESS"
  #         infos = {headers: {'content-type'=>'application/json; charset=utf-8'}, query: hash_data}
	 #        Rails.logger.debug "infos = #{infos}"
  #         resp = HTTParty.post("http://#{server_id}/jiyu/admin/tools/ucsdk", infos)
  #         if resp.to_s=="ok"
  #           Rails.logger.debug "hash_data=#{hash_data}"
  #           hash_data.delete("result")
  #           hash_data.delete("controller")
  #           hash_data.delete("action")
  #           charge_info.add_money = 1
  #           charge_info.save
  #            return "SUCCESS"
  #         end
  #         return "fail"
  #       else
  #         return "fail"
  #       end
  #     else
  #       return "SUCCESS"
  #     end
  # end
end
