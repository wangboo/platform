
require 'base64'
class ErrorLogController < ApplicationController

	skip_before_filter :verify_authenticity_token, :only => [:resove]

	def index
		@page_size = 10
		@size = ErrorLog.or({handled: false}, {handled: nil}).count
		# Rails.logger.debug "size = #{@size}"
		@page = @size / @page_size
		@page += 1 if @size % 20 > 0
		@cur_page = (params[:cur_page] or '1').to_i
		# 当前也不超过最大
		@cur_page = @page if @cur_page > @page
		start_index = (@cur_page - 1) * @page_size
		@errors = ErrorLog.or({handled: false}, {handled: nil}).skip(start_index).limit(@page_size).collect do |err|
			msg = err.error.split(/\n/)[1]
			err.same_num = ErrorLog.where(handled: false, error: /.*#{Regexp.quote(msg)}.*/).count
			err
		end

	end

	def resove
		if params[:same]
			log = ErrorLog.find(params[:id])
			error = log.error.split(/\n/)[1]
			# Rails.logger.debug("match err=#{error}, full=#{log.error}")
			# Rails.logger.debug("size = #{ErrorLog.where(handled: false, error: /.*#{Regexp.quote(error)}.*/).count}")
			size = ErrorLog.where(handled: false, error: /.*#{Regexp.quote(error)}.*/).update(handled: true)
		else
			ErrorLog.where(id: params[:id]).update(handled: true)
		end
		redirect_to error_log_path, cur_page: params[:cur_page]
	end

end