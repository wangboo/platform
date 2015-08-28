
class GroupController < ApplicationController 

	def index 
		@groups = Group.all
		@platforms = Platform.all.pluck(:id, :name, :mask)
		logger.debug "platforms = #{@platforms}"
		@new_group = Group.new 
	end 

	def create
		args = params[:group]
		name = args[:name]
		platform_ids = args.map{|k,v|if k =~ /p_.*/ then v else nil end}.compact.uniq
		Group.create(name: name, platform_ids: platform_ids)
		redirect_to groups_index_path
	end

	def delete 
		Group.find(params[:id]).delete
		redirect_to groups_index_path
	end

end