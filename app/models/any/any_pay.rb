require 'digest/md5'
require 'json'
class AnyPayServer
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
    keys = [:order_id,:product_count,:amount,:pay_status,:pay_time,:user_id,:order_type,:game_user_id,:server_id,:product_name,:product_id,:private_data,:channel_number,:sign,:source]
    keys.delete :sign
    data = keys.reduce({}){|s,a|s[a]=params[a];s}
    keys << :sign
    md5_str = data.to_a.sort{|v0,v1|v0[0]<=>v1[0]}.collect{|v|v[1]}.join
    private_key="351E7847A962A88D83FB9232C43BF1A7"
    Rails.logger.debug("md5_str = #{md5_str}")
    #md5_str = sort_params params
    md5 = md5_digest private_key,md5_str
# <<<<<<< Updated upstream
    #保存anysdk传过来的参数信息
    data = keys.reduce({}){|s,a|s[a]=params[a];s}
    
    product_id = params['product_id']
    list = [10,30,50,100,200,500,1000,2000]
    if amount.to_i != list.get(product_id.to_i -1)
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

  def self.uc_verify_pay params
    Rails.logger.debug "prams = #{params}"
    # body= params['body']
    hash_data = params['data']
    if hash_data["orderStatus"].to_s != "S"
      return "SUCCESS"
    end
    sign = params['sign']

    product_id = params["data"]["callbackInfo"].match(/productId=(.*)$/)[1]
    list = [10,30,50,100,200,500,1000,2000]
    if amount.to_i != list.get(product_id.to_i -1)
        hash_data['add_money']=0
        hash_data.delete("controller")
        hash_data.delete("action")
        hash_data.permit!
        UcChargeInfo.create hash_data
        return "SUCCESS"
    end

    Rails.logger.debug "hash_data111 = #{hash_data}"
      #hash_data={a=>b,c=>d}
    md5_str = ""
    hash_data.keys.sort.each do |key|
       value = hash_data[key]
       md5_str +=(key+"=#{hash_data[key]}")
    end
    Rails.logger.debug "md5_str=#{md5_str}"
    private_key = "a6fb07456626474f9ed441b455dc9922"
    md5 = Digest::MD5.hexdigest (md5_str+private_key)
    charge_info = UcChargeInfo.find_by orderId:hash_data["orderId"]
    server_id=params["data"]["callbackInfo"].match(/serverId=(.*)$/)[1]
    Rails.logger.debug "server_id = #{server_id}"
      if !charge_info
        if sign == md5
          hash_data['result']="SUCCESS"
          infos = {headers: {'content-type'=>'application/json; charset=utf-8'}, query: hash_data}
          resp = HTTParty.post("http://#{server_id}/jiyu/admin/tools/ucsdk", infos)
          if resp.to_s=="ok"
            # UcChargeInfo.create
            hash_data['add_money']=1
          else
            hash_data['add_money']=0
          end
          hash_data.delete("result")
          hash_data.delete("controller")
          hash_data.delete("action")
          Rails.logger.debug "hash_data2222=#{hash_data}"
          hash_data.permit!
          UcChargeInfo.create hash_data
          if resp.to_s == "ok"
             return "SUCCESS"
          else
             return "fail"
          end
        else
          "fail"
        end
      elsif charge_info.add_money == 0
        if sign == md5
          hash_data['result']="SUCCESS"
            infos = {headers: {'content-type'=>'application/json; charset=utf-8'}, query: hash_data}
	    Rails.logger.debug "infos = #{infos}"
          resp = HTTParty.post("http://#{server_id}/jiyu/admin/tools/ucsdk", infos)
          if resp.to_s=="ok"
            Rails.logger.debug "hash_data=#{hash_data}"
            hash_data.delete("result")
            hash_data.delete("controller")
            hash_data.delete("action")
            charge_info.add_money = 1
            charge_info.save
             return "SUCCESS"
          end
          return "fail"
        else
          return "fail"
        end
      else
        return "SUCCESS"
      end
  end
end
