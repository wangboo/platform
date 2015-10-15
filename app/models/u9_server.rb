require 'digest/md5'
class U9Server
	include HTTParty
	@default_options = {}
	@default_options[:headers] = {"Content-Type" => "application/json"}
	@default_options[:debug_output] = STDOUT
	base_uri "http://sdk.g.uc.cn/cp/"
	# base_uri "sdk.test4.g.uc.cn/cp/"

	class << self
	def game_id mask
		Rails.logger.debug "mask===#{mask}"
		if mask=="ANDROID-XICHU-ZHANSHEN-UC"
			"560484"
		else
			"557371"
		end
	end

	def api_key mask
		if mask=="ANDROID-XICHU-ZHANSHEN-UC"
			"cc0c51ccf5741d529d15291599a9f1e6"
		else
			"122a0218e344f51633710af7f64ccc12"
		end
	end

	def cp_id
		"55919"
	end

	def p uri, service, data,mask
		Rails.logger.debug "api_key==#{api_key(mask)}"
		Rails.logger.debug "game_id==#{game_id(mask)}"
		txt = data.collect{|i|i.join("=")}.join << api_key(mask)
		md5 = Digest::MD5.hexdigest txt
		post '/account.verifySession', body: {id: Time.now.to_i, service: service,game: {gameId: game_id(mask)},
			data: data, sign: md5}.to_json
	end

	def login sid,mask
		resp = p("/account.verifySession", "account.verifySession", {sid: sid},mask)
		JSON.parse(resp)
	end

	end
end
