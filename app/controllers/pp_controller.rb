require 'net/http'
require 'open-uri'
require 'base64'

class PpController < AppSideController

  PP_PEM = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApx/pwU0+DM5GlFkA5XTu\nCLqKf6Se9AyhIAqHCCHmDPp2DJQSguO2wGp0Nit97cZ20vcefVjuEICf2dd4hga/\n2MurRJwPB6v/s5M511rBWftU9SVa493Cvdtg/bgdhNf/z4Gja3mFrin+EMxRn051\n1+dg8YRhhjpMfMkZo4uGC6wX4FuYSLMFUz9uYLhuRiv+Z+Q+S7gidQdMh2+zftAu\nQXOwbzaAa6TUicHeG6arNEv731Vb3RJS43/qDmjoQe6m+mjPzkvs8cti9aZG7BeW\n1BIVFFvNdEU281+foWx1SjB+FVhyWQm2fbnJlsDuIBTkNZ0Jrp4wW06c+aaJM1Dw\nsQIDAQAB\n-----END PUBLIC KEY-----"

	def self.app_key
		@app_key ||= 'c74923d3c2cd4078b03e85b6cb89f57e'
	end

	def self.appid
		@appid ||= 6111
	end

	def self.login token
		txt = "sid=#{token}#{PpController.app_key}"
		md5 = Digest::MD5.hexdigest txt
		body = {id: Time.now.to_i, service: 'account.verifySession',game: {gameId: PpController.appid}, data: {sid: token}, sign: md5}
		Rails.logger.debug "body = #{body.to_json}"
		HTTPClient.new.post('http://120.31.134.126:8080/account?tunnel-command=2852126760', body: body.to_json).body
	end

	def success msg=nil
		Rails.logger.debug msg if msg
		render json: 'success'
	end

	def fail msg=nil
		Rails.logger.debug msg if msg
		render json: 'fail'
	end

	def verify_pay
		data = JSON.parse decrypt
		if data.each.to_a.index{|k,v|params[k] != v.to_s}
			Rails.logger.debug "签名验证不通过"
			return fail
		end
		payment = HashWithIndifferentAccess.new(
		order_id:           data['billno'],
		platform_order_id:  data['order_id'],
		state:              data['status'].to_i == 0,
		money:              data['amount'].to_i,
		params:             params.to_json
		)
		IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
	end

	def decrypt
		data = Base64.decode64 params[:sign]
		OpenSSL::PKey::RSA.new(PP_PEM).public_decrypt data
	end

end
