# 游戏服务器端控制器
class GameServersController < AppSideController

	# 验证QIC平台的登陆用户的token
	def applogin
		user = QicUser.where(username: params[:username]).first
		return resp_app_f '用户名不存在' unless user
		Rails.logger.debug "user.token=#{user.token}"
		Rails.logger.debug "para.token=#{params[:token]}"

		return resp_app_f 'token验证错误' unless user.token == params[:token]
		resp_app_s
	end



end