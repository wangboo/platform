require 'net/http'
require 'open-uri'

class PPController < AppSideController

	def self.app_key
		@app_key ||= '439fcd9d8309613c4dc3ceae8b1a4fbb'
	end

	def self.appid
		@appid ||= 5329
	end

	def self.login token
		txt = "sid=#{token}#{PPController.app_key}"
		md5 = Digest::MD5.hexdigest txt
		body = {id: Time.now.to_i, service: 'account.verifySession',game: {gameId: PPController.appid}, data: {sid: token}, sign: md5}
		Rails.logger.debug "body = #{body.to_json}"
		HTTPClient.new.post('http://120.31.134.126:8080/account?tunnel-command=2852126760', body: body.to_json).body
		# open('http://120.31.134.126:8080/account?tunnel-command=2852126760', body: body.to_json).body
	end 

	def success
		render json: 'success'
	end

	def fail
		render json: 'fail'
	end

	def verify_pay

		success
	end

end