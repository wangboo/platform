class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :auth_check

  def auth_skip_list
  	@@skip_list = [auth_login_path, auth_logout_path]
  end

  def auth_check
  	Rails.logger.debug "request.remote_ip = #{request.remote_ip}"
  	path = request.path 
  	unless auth_skip_list.include?(path) or path =~ /^\/app\// or request.remote_ip =~ /10\.8/ or request.remote_ip == '127.0.0.1'
  		# 权限检查
	  	unless cookies[:bawang_auth] == auth_key
				redirect_to auth_view_path
				return false
			end
		end
		true
  end 

  private
	def auth_key
		@@auth_key ||= SecureRandom.hex(24)
	end

end


