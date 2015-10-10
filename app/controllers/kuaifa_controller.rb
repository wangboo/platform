require 'base64'
require 'digest/md5'
class KuaifaController < AppSideController

	def self.login_url
		"http://z.kuaifazs.com/foreign/oauth/verification2.php"
	end
#GameKey:5b698dfefa12cd12453bd6020e812f77
#SecurityKey:Idkm4hRccAEOU5sZ4WewWLllNzg0J7YV

	def self.login token,openId
		Rails.logger.debug "token ====== #{token}"
		Rails.logger.debug "openId ====== #{openId}"
		hash = Hash.new
		hash['token']=token
		hash['openid']=openId
		hash['timestamp']=Time.new
		hash['gamekey']='5b698dfefa12cd12453bd6020e812f77'
		beSign = hash.keys.sort.map{|k|"#{k}=#{CGI::escape(hash[k].to_s)}"}.join('&')
		hash['_sign']= Digest::MD5.hexdigest(Digest::MD5.hexdigest(beSign)+"Idkm4hRccAEOU5sZ4WewWLllNzg0J7YV")

		begin
			resp = HTTParty.post(login_url, body: hash.to_json).body
			rst = JSON.parse resp
			Rails.logger.debug "rst['result'] ====== #{rst["result"]}"
			return [-1, 0] unless rst["result"] == 0
			account_id = openId
    	user = QicUser.find_or_create_by(username: account_id) do |u|
      	u.username = account_id
      	u.password = ""
    	end
    	return [user, account_id]
		rescue => e
			Rails.logger.error "login to kuaifa error #{e}"
			return [-1, 0]
		end

	end

	# def pay_key
	# 	"ad0967bff9e8355628bae081cad69241"
	# end

	def fail msg=nil
		Rails.logger.debug msg if msg
		# render json: {"result":"1","result_desc":msg}
		render json: "{'result':'1','result_desc':#{msg}}"
	end

	def success msg=nil
		Rails.logger.debug msg if msg
		# render json: {"result":"0","result_desc":"接收成功"}
		render json: "{'result':'0','result_desc':'接收成功'}"
	end

	def sign_keys
		%w(serial_number cp timestamp result extend server product_id product_num game_orderno amount)
	end

  	def verify_pay
  		Rails.logger.debug "params[:result]====#{params[:result].to_i}"
  		return fail "订单状态为失败" unless params[:result].to_i == 0
    	beSign = sign_keys.map.sort.map{|k|"#{key}=#{CGI::escape(params[k].to_s)}"}.join('&')
    	md5 = Digest::MD5.hexdigest(Digest::MD5.hexdigest(beSign)+"Idkm4hRccAEOU5sZ4WewWLllNzg0J7YV")
    	Rails.logger.debug "params[:_sign]====#{params[:_sign]}"
    	Rails.logger.debug "md5===========#{md5}"
    	return fail "校验签名失败" unless md5 == params[:_sign]
    	payment = HashWithIndifferentAccess.new(
	    order_id:           params['serial_number'],
	    platform_order_id:  '0',
	    state:              params[	'result'].to_i == 0,
	    money:              params['amount'].to_i,
	    params:             params.to_json
    )
    	IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
  	end
end