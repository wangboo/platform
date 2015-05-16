# bgm后台
class BgmController < ApplicationController

	def index
		@bgms = GmAccount.all 
		@new_bgm = GmAccount.new 
	end

	def create
		bgm_params = params.require(:bgm).permit(:username, :password)
		logger.debug "bgm_params = #{bgm_params}"
		GmAccount.create(bgm_params)
		redirect_to(bgm_index_path)
	end

end