require 'digest/md5'
class U9Server
	include HTTParty
	@default_options = {}
	@default_options[:headers] = {"Content-Type" => "application/json"}
	@default_options[:debug_output] = STDOUT
	base_uri "http://sdk.g.uc.cn/cp/"

	class << self
	def game_id
		"542891"
	end

	def api_key
		"a6fb07456626474f9ed441b455dc9922"
	end

	def cp_id
		"47585"
	end

	def p uri, service, data
		txt = data.collect{|i|i.join("=")}.join << api_key
		md5 = Digest::MD5.hexdigest txt
		post '/account.verifySession', body: {id: Time.now.to_i, service: service,game: {gameId: game_id}, 
			data: data, sign: md5}.to_json
	end

	def login sid
		resp = p("/account.verifySession", "account.verifySession", {sid: sid})
		JSON.parse(resp)
	end

	end
end
