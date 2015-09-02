
class GroupController < ApplicationController 

	before_action :find_group, except: [:index, :create]

	def index 
		@groups = Group.all
		@platforms = Platform.all.pluck(:id, :name, :mask)
		logger.debug "platforms = #{@platforms}"
		@new_group = Group.new 
	end 

	def show 
		all_ids = Platform.all.pluck(:id, :mask)
		@owned_platforms = Platform.in(id: @group.platform_ids).pluck(:id, :mask).sort{|a,b|a[1] <=> b[1]}
		@other_platforms = (all_ids - @owned_platforms).sort{|a,b|a[1] <=> b[1]}
	end

	def create
		args = params[:group]
		name = args[:name]
		platform_ids = args.map{|k,v|if k =~ /p_.*/ then v else nil end}.compact.uniq
		Group.create(name: name, platform_ids: platform_ids)
		redirect_to groups_index_path
	end

	def delete 
		@group.delete
		redirect_to groups_index_path
	end

	def rmplatform
		@group.platform_ids.delete(params[:pid])
		@group.save 
		redirect_to group_show_path(@group)
	end

	def addplatform
		@group.platform_ids << params[:pid]
		@group.save 
		redirect_to group_show_path(@group)
	end

	def update
		@group.update_attributes(name: params[:name])
		redirect_to group_show_path(@group)
	end

	private
	def find_group
		@group = Group.find(params[:id])
	end

end