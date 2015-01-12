class ActiveTypesController < ApplicationController

	before_action :find_active_type, only: [:update]

  def index
  	@active_types = ActiveType.all.order("id asc")
  	@new_active_type = ActiveType.new
  end

  def create
  	ActiveType.create active_type_params
  	redirect_to active_types_path
  end

  def update
    # Rails.logger.debug("active_type update=#{active_type_params}")
  	@active_type.update active_type_params
  	redirect_to active_types_path
  end

  def delete
  end

  def active_type_params
  	params.require("active_type").permit(:name, :desc, :mask)
  end

  def find_active_type
  	@active_type = ActiveType.find(params[:id])
  end

end
