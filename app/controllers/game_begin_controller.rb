require 'open-uri'
require 'digest/md5'

class GameBeginController < AppSideController

	GB_ENV=0
	GB_ADDR_ROOT='www.gamebegin.com'
	GB_ADDR_TEST='edit.gamebegin.com'
	GB_GAME_ID=16
	GB_GAME_KEY='sxcq_i'
	GB_GAME_PAY_KEY="3zShuVfxaghHSB95Nxv5as26LIk9sdVf"

	def self.game_key
		@game_key ||= 'sxcq_i'
	end

	def self.gameid
		@gameid ||= 16
	end

	def self.login params
		host = (GB_ENV == 1) ? GB_ADDR_ROOT : GB_ADDR_TEST
		uid = params[:uid]
		token = params[:token]
		body = HTTParty.post("http://#{host}/sdkapi-checktoken.html?GameId=#{GB_GAME_ID}&GameKey=#{GB_GAME_KEY}&Uid=#{uid}&Token=#{token}").body
	end

	def success msg=nil
		Rails.logger.debug msg if msg
		render json: '1'
	end

	def fail code,msg=nil
		Rails.logger.debug msg if msg
		render json: code
	end

	def verify_pay
		Rails.logger.debug "params=#{params}"
		if params["OrderStatus"] != "S"
			# return "7"
			return fail '7'
		end
		return fail '3' unless params['Amount'].to_i >= 0

		keys = [:OrderId,:GameId,:ServerId,:Uid,:Amount,:CallbackInfo,:OrderStatus,:Time]
		order_id,game_id,server_id,uid,amount,call_back_info,order_status,time = keys.map{|k|params[k]}
		call_back_info=call_back_info.gsub(/[^a-zA-Z0-9_\-.]/n){ sprintf("%%%02X", $&.unpack("C")[0]) } 
		md5_str="#{order_id}#{game_id}#{server_id}#{uid}#{amount}#{call_back_info}#{order_status}#{time}"
		data = keys.reduce({}){|s,a|s[a]=params[a];s}
		md5 = md5_digest GB_GAME_PAY_KEY,md5_str
		charge_info = GbChargeInfo.find_by OrderId:params["OrderId"]
		if !charge_info
			if md5.to_s == params['Sign'].to_s
				#调游戏后台服务器
				data["result"] = "SUCCESS"
				infos = {headers: {'content-type'=>'application/json; charset=utf-8'}, query: data}
				resp = HTTParty.post("http://203.195.181.103:4567/gb_pay", infos)
				#
				if resp.to_s == "ok"
					data['AddMoney']=1
				else
					data['AddMoney']=0
				end
				data.delete("result")
				GbChargeInfo.create data
				if resp.to_s == "ok"
					return success
				else
					return fail '7'
				end
			else
				return fail '4'
			end
		elsif charge_info.AddMoney.to_i == 0
			if md5 == params['Sign'].to_s
				#调游戏后台服务器
				data["result"] = "SUCCESS"
				infos = {headers: {'content-type'=>'application/json; charset=utf-8'}, query: data}
				resp = HTTParty.post("http://203.195.181.103:4567/gb_pay", infos)
				#
				Rails.logger.debug "resp=#{resp}"
				if resp.to_s == "ok"
					charge_info.AddMoney = 1
					charge_info.save
					# return "1"
					return success
				end
				# return "7"
				return fail '7'
			else
				# return "4"
				return fail '7'
			end
		else
			# return "5"
			return fail '5'
		end

	end


	def md5_digest private_key,md5_str
		md5 = Digest::MD5.hexdigest md5_str+private_key
		return md5
	end

end