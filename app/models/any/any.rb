require 'digest/md5'
class AnyServer
	include HTTParty
	@default_options = {}
<<<<<<< HEAD
	@default_options[:headers] = {"Content-Type" => "application/json"}
=======
	@default_options[:headers] = {"Content-Type" => "application/x-www-form-urlencoded;charset=utf-8"}
>>>>>>> 833f4aad7b008cbeb5e43c400df3a893a2d85921
	@default_options[:debug_output] = STDOUT
	base_uri "http://oauth.anysdk.com/api/User/"

	class << self
<<<<<<< HEAD
=======
		
>>>>>>> 833f4aad7b008cbeb5e43c400df3a893a2d85921
		def game_id
			"542891"
		end

		def api_key
			"A3555DC1-2DF3-A579-91C6-80A66D4B1191"
		end
		def api_secret
			"dd6f4b39cea319da78f7e07623ff7331"
		end

		def cp_id
			"47585"
		end

<<<<<<< HEAD

		def p data
			Rails.logger.debug "data=#{data}"
			post 'http://oauth.anysdk.com/api/User/LoginOauth/', query: data
=======
		def p data
			Rails.logger.debug "data=#{data}"
			post 'http://oauth.anysdk.com/api/User/LoginOauth/', body: data
>>>>>>> 833f4aad7b008cbeb5e43c400df3a893a2d85921
		end

		def verify params
			#校验必要参数
			resp = p(params)
		end

	end
end
