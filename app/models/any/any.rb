require 'digest/md5'
class AnyServer
	include HTTParty
	@default_options = {}
	@default_options[:headers] = {"Content-Type" => "application/json"}
	@default_options[:debug_output] = STDOUT
	base_uri "http://oauth.anysdk.com/api/User/"

	class << self
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


		def p data
			Rails.logger.debug "data=#{data}"
			post 'http://oauth.anysdk.com/api/User/LoginOauth/', query: data
		end

		def verify params
			#校验必要参数
			resp = p(params)
		end

	end
end
