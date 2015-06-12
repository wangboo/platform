class ManageController < ApplicationController 

	before_action :find_manage

	def index 
		@platforms = Platform.all
	end

	def update_white_ips
		@manage.white_ips = params[:whiteIPs].split(";")
		@manage.save 
		render text: "ok"
	end

	def update_white_ips_on
		@manage.white_ips_on = params[:checked] == 'true'
		@manage.save 
		render text: "ok"
	end

	def update_white_ips_notice
		@manage.white_ips_notice = params[:notice]
		@manage.save 
		render text: "ok"
	end 

	def update_white_platform_on
		@manage.white_platform_on = params[:checked] == 'true'
		@manage.save 
		render text: "ok"
	end

	def update_white_platform_all
		@manage.white_platform = Platform.all.pluck(:mask)
		@manage.save
		render text: "ok"
	end	

	def update_white_platform_notice
		@manage.white_platform_notice = params[:notice]
		@manage.save 
		render text: "ok"
	end 

	private
	def find_manage
		@manage = Manage.find_or_create_by(){}
	end

end