require 'securerandom'
# 权限
class AuthController < ApplicationController

	def login
		if cookies[:bawang_auth] == auth_key
			return redirect_to server_index_path
		end
		@err = false
		render :login, layout: false
	end

	def logout
		cookies[:bawang_auth] = nil
		redirect_to auth_view_path
	end

	# 验证账号密码
	def validate
		if params[:auth][:username] == 'bawang' and params[:auth][:password] == 'xiangyuniubi'
			cookies[:bawang_auth] = {value: auth_key, expires: 8.hours.from_now}
			redirect_to server_index_path
		else
			@err = true
			render :login, layout: false
		end
	end

end
