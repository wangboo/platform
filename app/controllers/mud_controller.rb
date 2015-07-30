class MudController < AppSideController

	def self.zone_id
		10301001
	end

	def self.login_url
		"http://mgameapi.mud001.com/user/775/1030"
	end

	def self.login token, user_ip
		post_data = {zone_id: zone_id, gs_time: Time.now.to_i, user_ip: user_ip, channel_id: 0, user_token: token, app_data: ""}.to_json
		begin
      Rails.logger.debug "url = #{login_url}, post_data = #{post_data}"
			resp = HTTParty.post(login_url, body: post_data).body
      Rails.logger.debug "mud resp = #{resp}"
			rst = JSON.parse resp
			return [-1, 0] unless rst["user_account"] and rst["result_id"] == 0
			account_id = rst["user_account"]
    	user = QicUser.find_or_create_by(username: account_id) do |u|
      	u.username = account_id
      	u.password = ""
    	end
    	return [user, account_id]
		rescue => e
			Rails.logger.error "login to mud error #{e}"
			return [-1, 0]
		end

	end

	def keys
		%w{detail_status detail_id zone_id channel_id user_account gs_time}
	end

	def pay_key
		"ad0967bff9e8355628bae081cad69241"
	end

	def response_to_mud params, detail_status=0, msg=nil
		Rails.logger.error("mud charge fail #{msg}, params=#{params}") unless detail_status == 0
		data = {
			detail_status: detail_status,
			detail_id: params["detail_id"],
			zone_id: self.class.zone_id,
			channel_id: 0,
			user_account: params["user_account"],
			gs_time: Time.now.to_i
		}
		md5_be = data.to_a.map{|k,v|"#{k}=#{v}"}.sort.join << pay_key
    Rails.logger.debug "resp md5_be = #{md5_be}"
		md5_af = Digest::MD5.hexdigest md5_be
		data['sn'] = md5_af
		render json: data
	end

	def verify_pay
    data = request.body.read
    logger.debug "data.class = #{data.class}, data = #{data}"
    data = JSON.parse(data)
    sn = data.delete('sn')
		md5_be = data.to_a.map{|k,v|"#{k}=#{v}"}.sort.join << pay_key
		md5_af = Digest::MD5.hexdigest md5_be
    logger.debug "md5_before = #{md5_be}"
    logger.debug "md5_af = #{md5_af}"
		return response_to_mud(data, 1, "md5签名错误") unless md5_af == sn
		payment = HashWithIndifferentAccess.new(
      order_id:           data['app_data'],
      platform_order_id:  data['detail_id'],
      state:              true,
      money:              data['amount'].to_i/100,
      params:             data.to_json
    )
    IOSChargeInfo.charge payment, proc{|m|response_to_mud(data, 0, m)}, proc{|m|response_to_mud(data, 1, m)}
	end

end
