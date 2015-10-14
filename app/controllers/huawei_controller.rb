require 'base64'
require 'digest/md5'
class HuaweiController < AppController

	def self.app_id
		1000019559
	end

	def self.keys
		@keys ||= [:result, :userName, :productName, :payType, :amount, :orderId,
			:notifyTime, :requestId, :bankId, :orderTime, :tradeTime, :accessMode, :spending,
			:extReserved, :sysReserved]
	end

#	def self.login token, user_in
#		begin
#	    	user = QicUser.find_or_create_by(username: user_in) do |u|
#		      	u.username = account_id
#		      	u.password = ""
#	    	end
 #   	return [user, account_id]
	# def self.login token
	# 	begin
	#     	user = QicUser.find_or_create_by(username: user_in) do |u|
	# 	      	u.username = account_id
	# 	      	u.password = ""
	#     	end
 #    	return [user, account_id]
	# 	rescue => e
	# 		Rails.logger.error "login to mud error #{e}"
	# 		return [-1, 0]
	# 	end
	# end

	def self.login token
		txt = CGI::escape tokoen
		md5 = txt.sub(/[+]/,'%2B')
		# body = {id: Time.now.to_i, service: 'account.verifySession',game: {gameId: PpController.appid}, data: {sid: token}, sign: md5}
		body = {nsp_svc: 'openUP.User.getInfo', nsp_ts: Time.now.to_i, access_token: md5}
		bodys = body.keys.map{|k|"#{k}=#{body[k]}"}.join('&')
		Rails.logger.debug "body = #{body.to_json}"

		begin
			resp = HTTParty.post('https://api.vmall.com/rest.php', body: bodys.to_s).body
			# resp = HTTParty.post(login_url, body: hash.to_json).body
			rst = JSON.parse resp
			account_id = resp['userID']
			if nil == account_id
				return [-1, 0]
			end
    		user = QicUser.find_or_create_by(username: account_id) do |u|
      			u.username = account_id
      			u.password = ""
    		end
    		return [user, account_id]
		rescue => e
			Rails.logger.error "login to huawei error #{e}"
			return [-1, 0]
		end
	end

	def self.pay_key
		"c0e24702a24d4c48b3ca4c0646138bff"
	end

	def fail msg=nil
		Rails.logger.debug msg if msg
		render json: {"result": msg}
	end

	def success msg=nil
		Rails.logger.debug msg if msg
		render json: {"result": msg}
	end

	# 支付接口
	def verify_pay
		md5_str = sort_params(params).map{|k|"#{k}=#{params[k]}"}.join("&")
		# md5_str = ERB::Util.url_encode(md5_str)
		Rails.logger.debug "md5_str = #{md5_str}"
		Rails.logger.debug "#{params[:sign]}"
		unless params[:sign] == Digest::MD5.hexdigest(md5_str+pay_key)
			Rails.logger.debug "签名校验失败"
			return fail 1
		end
		payment = HashWithIndifferentAccess.new(
	      order_id:           params['orderId'],
	      platform_order_id:  '0',
	      state:              params['result'].to_i == 0,
	      money:              params['amount'].to_i,
	      params:             params.to_json
    	)
   		IOSChargeInfo.huawei_charge payment, proc{|m|success m}, proc{|m|fail m}
	end

	def self.sort_params params
    	keys = []
	    params.keys.sort.each do |key|
	      if key != "sign" && key != "signType"
	         keys<<key
	      end
	    end
	    return keys
 	end

end
