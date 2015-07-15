class MudController < AppSideController

	def self.zone_id
		10301001
	end

	def self.login_url
		""
	end

	def self.login token, user_ip
		post_data = {zone_id: zone_id, gs_time: Time.now.to_i, user_ip: user_ip, channel_id: 0, user_token: token, app_data: ""}
		begin
			resp = HTTParty.post(login_url, post_data).body
			rst = JSON.parse resp
			return [-1, 0] unless rst["user_account"]
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
		""
	end

	def response_to_mud params, detail_status=0, msg=nil
		Rails.logger.error("mud charge fail #{msg}, params=#{params}") unless detail_status == 0
		data = {
			detail_status: detail_status,
			detail_id: params[:detail_id],
			zone_id: self.class.zone_id,
			channel_id: 0,
			user_account: params[:user_account],
			gs_time: Time.now.to_i
		}
		md5_be = data.to_a.map{|k,v|"#{k}=#{v}"}.join << pay_key
		md5_af = Digest::MD5.hexdigest md5_be
		data[:sn] = md5_af
		render json: data
	end

	def verify_pay
		md5_be = params.map{|k|"#{k}=#{params[k]}"}.join << pay_key
		md5_af = Digest::MD5.hexdigest md5_be
		return response_to_mud(params, 1, "md5签名错误") unless md5_af == params[:sn]
		payment = HashWithIndifferentAccess.new(
      order_id:           params['app_data'],
      platform_order_id:  params['detail_id'],
      state:              true,
      money:              params['amount'].to_i/100,
      params:             params.to_json
    )
    IOSChargeInfo.charge payment, proc{|m|response_to_mud(params, 0, m)}, proc{|m|response_to_mud(params, 1, m)}
	end

end