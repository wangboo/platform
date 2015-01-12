puts "init Comm"

# 通信工具
class GameServer
	
	# 调用管辖服务器上的服务
	def self.call_server server, name, params={}
		Rails.logger.debug("http://#{server.ip}:#{server.port}/jiyu/admin/#{name}")
		HTTPClient.get_content("http://#{server.ip}:#{server.port}/jiyu/admin/#{name}",params)
	end

	# 调用cmd服务
	def self.call_cmd server, cmd, params={}
		params[:cmd] = cmd.to_s
		call_server server, "/master/cmd", params
	end

end
