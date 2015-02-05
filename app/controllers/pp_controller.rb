require 'net/http'
require 'open-uri'
require 'base64'

class PpController < AppSideController

	PP_PEM = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA29hYrlTLzXGX284Yu5lw\nc09k8iNpNYBvbFoQfGOrYRgD3l1+nZtX1qPtKHwVVFG2UKih9cQT8gc/BsCzkxIO\nnSHP4wtI8m4kttbs+b+DGstZnQLgRoTa+zzGJWhDSY5Gngg2xXfh7Ewx1SPdLoiP\nfaFKj8/MNjGfZz1iI3wmWMLDJftFc6drd42LBT63Qoph9dBZZlnxgINWiGHGpeZC\nGoxalcYyt+gH+h+w5Og2+lsvrH4IWSzk6eRSt8qi8rDK9lJOw0rHtqhpbAgaAs3k\nfDml1yFlzT3XrP5FvLo09wigg/q/8egcssXCdFuO//42jPaCk0H9HpZrmjQFK8Au\nXQIDAQAB\n-----END PUBLIC KEY-----"


	#PP_PEM = "-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC2kcrRvxURhFijDoPpqZ/IgPlA\ngppkKrek6wSrua1zBiGTwHI2f+YCa5vC1JEiIi9uw4srS0OSCB6kY3bP2DGJagBo\nEgj/rYAGjtYJxJrEiTxVs5/GfPuQBYmU0XAtPXFzciZy446VPJLHMPnmTALmIOR5\nDddd1Zklod9IQBMjjwIDAQAB\n-----END PUBLIC KEY-----"

	def self.app_key
		@app_key ||= '439fcd9d8309613c4dc3ceae8b1a4fbb'
	end

	def self.appid
		@appid ||= 5329
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
