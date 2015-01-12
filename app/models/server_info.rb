require Rails.root.join("lib", "comm.rb")

class ServerInfo

	include Mongoid::Document
	include Mongoid::Timestamps

	belongs_to :server
	# 时间
	field :time,							type: Integer, default: -> {Time.now.strftime('%Y%m%d%H').to_i}
	# 在线人数
	field :onlineSize, 				type: Integer
	# 在线时长
	field :onlineDaylong, 		type: Integer
	# 请求次数
	field :requestTimes, 			type: Integer
	# 用户数
	field :userSize, 					type: Integer
	# 当日活跃用户
	field :requestUserSize, 	type: Integer
	# 银两总数
	field :silverSum, 				type: Integer
	# 元宝总数
	field :goldSum, 					type: Integer
	# 赠送元宝总数
	field :donateSum, 				type: Integer
	# 金券总数
	field :voucherSum, 				type: Integer
	# 银两消耗
	field :silverCost, 				type: Integer
	# 元宝消耗
	field :goldCost, 					type: Integer
	# 金券消耗
	field :voucherCost, 			type: Integer
	# 赠送元宝消耗
	field :donateCost, 				type: Integer

	# cron每个小时取一次服务器数据，放在该表中
	# {"sysCost":{"id":1,"silverCost":290540,"goldCost":30,"donateCost":0,"voucherCost":2230,"amCost":0,"silverOut":0,
	# "goldOut":0,"voucherOut":0,"donateOut":0,"amOut":0},"goldSum":168157933,"onlineDaylong":0,"r":"s",
	# "voucherSum":444674,"donateSum":0,"userSize":111,"requestUserSize":11,"requestTimes":1706,"onlineSize":1}
	def self.cron_update
		Server.each do |server|
			rst_json = GameServer.call_cmd(server, "server_info")
			rst = JSON.parse(rst_json)
			ServerInfo.create do |info|
				info.server = server
				info.onlineSize = rst["onlineSize"]
				info.onlineDaylong = rst["onlineDaylong"]
				info.requestTimes = rst["requestTimes"]
				info.userSize = rst["userSize"]
				info.requestUserSize = rst["requestUserSize"]

				info.silverSum = rst["silverSum"]
				info.goldSum = rst["goldSum"]
				info.donateSum = rst["donateSum"]
				info.voucherSum = rst["voucherSum"]

				info.silverCost = rst["sysCost"]["silverCost"]
				info.goldCost = rst["sysCost"]["goldCost"]
				info.donateCost = rst["sysCost"]["donateCost"]
				info.voucherCost = rst["sysCost"]["voucherCost"]
			end
		end
	end



end