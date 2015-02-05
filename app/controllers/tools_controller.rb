#encoding: utf-8
# 工具
class ToolsController < ApplicationController
	include ToolsHelper
	before_action :tools_before_action, except: [:web_console, :notice_modify]

	@@check_server_fields = %w(ssh_user ssh_pwd project_path mysql_user mysql_pwd mysql_database mysql_host)

	def tools_before_action
		@platform = Platform.find(params[:id])
		@servers = @platform.servers
		if request.xml_http_request?
			if params[:reward] and not /^(\w+(\-\d+){1,2}\,){0,}(\w+(\-\d+){1,2})$/ =~ params[:reward] 
				render json: {rst: "处理失败", msgs: ["奖励表达式错误", "don't match /^(\w+(\-\d+){1,2}\,){0,}(\w+(\-\d+){1,2})$/"]}
				return false
			end
			@servers = if params[:servers] == 'all'
				@platform.servers
			else
				Server.where(id:params[:servers])
			end
			if @servers.empty? 
				render json: {rst: "处理失败", msgs: "在#{@platform.name}找不到服务器 #{params[:servers]}"}
				return false 
			end
			if params[:servers] 
				# 检查服务器配置是否齐全
				@servers.any? do |s|
					if nil_field = @@check_server_fields.find{|f|if s[f] == nil or s[f].empty? then f else false end}
						render json: {rst: "处理失败", msgs: "服务器<#{s.name}>,ip=(#{s.ip}) 配置项#{nil_field}为空"}
						return false
					end
				end
			end 
		else
			# html
		end 
	end

	# 奖品界面
	def reward_to_user_view 
	end

	def reward_to_platform_view
	end

	# 发奖给指定平台的人
	def reward_to_platform
		names = params[:names]
		to_platform = Platform.find(params[:to_platform])
		msgs = []
		@servers.each do |s|
			sync s
			p = send_mail(s, type: "reward", prefix: to_platform.mask)
			p.force_encoding("utf-8")
			msgs << "#{s.name} - #{s.ip} - #{p}"
		end
		render json: {rst: "处理成功", msgs: msgs}
	rescue => e
		Rails.logger.error e.message
		Rails.logger.error e.backtrace.join("\n")
		render json: {rst: "发奖失败 #{e.message}", msgs: []}
	end

	# 给指定人发奖品
	def reward_to_user
		names = params[:names]
		msgs = []
		@servers.each do |s|
			sync s
			p = send_mail(s, type: "reward", user: names)
			p.force_encoding("utf-8")
			msgs << "#{s.name} - #{s.ip} - #{p}"
		end
		render json: {rst: "处理成功", msgs: msgs}
	rescue => e
		Rails.logger.error e.message
		Rails.logger.error e.backtrace.join("\n")
		render json: {rst: "发奖失败 #{e.message}", msgs: []}
	end
	# 指定条件
	def reward_to_condition_view
		@tag = "reward_to_condition_view"
	end
	# 指定条件 发奖
	def reward_to_condition
		[["registBegin","注册早于"], ["registAfter",'注册晚于']].each do |key,name|
			if params[key] and not params[key] =~ /^\d{4}\-\d{2}\-\d{2}\s\d{2}:\d{2}$/
				render json: {rst: "发奖失败", msgs: "**#{name}**必须为 /^\d{4}\-\d{2}\-\d{2}\s\d{2}:\d{2}$/ "}
				return
			end
		end
		[["levelBigger","等级大于"], ["levelSmaller","等级小于"]].each do |key,name|
			if params[key] and not params[key] =~ /^\d+$/
				render json: {rst: "发奖失败", msgs: "**#{name}**必须为正整数"}
				return
			end
		end
		# 发奖
		msgs = ""
		@servers.each do |s|
			sync s
			hash = params.permit("registBegin", "registAfter", "levelBigger", "levelSmaller").merge(type: 'reward')
			p = send_mail(s, hash)
			p.force_encoding("utf-8")
			msgs << "#{s.name} - #{s.ip} - #{p}"
		end
		render json: {rst: "处理成功", msgs: msgs}
	rescue => e
		Rails.logger.error e.message
		Rails.logger.error e.backtrace.join("\n")
		render json: {rst: "发奖失败 #{e.message}", msgs: []}
	end

	def notice_view
	end
	# 发公告
	def create_notice
		msgs = ""
		args = params.permit(:begin_date,:end_date,:details,:title,:range)
		args[:title] 		= CGI::escape args[:title]
		args[:details] 	= CGI::escape args[:details]
		args[:range] 		= CGI::escape args[:range]
		@servers.each do |s|
			rst = post(s, "/addNotice", args)
			msgs << "#{s.name} - #{s.ip} - #{rst}"
		end
		Rails.logger.debug "create_notice #{msgs}"
		render json: {rst: "发公告成功", msgs: msgs}
	rescue => e
		Rails.logger.error e.message
		Rails.logger.error e.backtrace.join("\n")
		render json: {rst: "发奖失败 #{e.message}", msgs: []}
	end

	def notice_modify_view
		@query_server = if params[:query_server_id]
			Rails.logger.debug "params[:query_server_id] = #{params[:query_server_id]}"
			Server.find(params[:query_server_id])
		else
			@servers.first
		end
		Rails.logger.debug "@query_server = #{@query_server}"
		@data = HTTParty.get(@query_server.query_notice_url).body
		@data = JSON.parse @data
	rescue
		@data = []
	end

	# 提交公告改动
	def notice_modify
		server = Server.find(params[:sid])
		data = params.permit(:noticeId, :sort, :range, :title, :details, :beginDate, :endDate)
		logger.debug "before data = #{data} #{params[:beginDate].match(/^\d{4}\-\d\d\-\d\d \d\d:\d\d:\d\d$/)} -- "
		return render json: {msg: "开始时间格式不对"} unless params[:beginDate].match(/^\d{4}\-\d\d\-\d\d \d\d:\d\d:\d\d$/)
		return render json: {msg: "结束时间格式不对"} unless params[:endDate].match(/^\d{4}\-\d\d\-\d\d \d\d:\d\d:\d\d$/)
		data[:beginDate] 	= DateTime.strptime(data[:beginDate], "%Y-%m-%d %H:%M:%S").to_time.to_i * 1000
		data[:endDate] 		= DateTime.strptime(data[:endDate], "%Y-%m-%d %H:%M:%S").to_time.to_i * 1000
		# logger.debug "#{server.update_notice_url} data = #{data}"
		resp = HTTParty.post(server.update_notice_url, body: data).body
		render json: {msg: "ok"}
	rescue => e 
		logger.debug "notice_modify error #{e}"
		render json: {msg: 'error'}
	end

	def scroll_msg_view
	end

	def scroll_msg
		msgs = ""
		args = params.permit(:name, :message)
		Rails.logger.debug "scroll_msg #{args}"
		args[:name] 		= CGI::escape args[:name]
		args[:message] 	= CGI::escape args[:message]
		Rails.logger.debug "scroll_msg escape #{args}"
		@servers.each do |s|
			rst = post(s, "/scrollMsg", args)
			msgs << "#{s.name} - #{s.ip} - #{rst}"
		end
		Rails.logger.debug "create_notice #{msgs}"
		render json: {rst: "发布消息成功", msgs: msgs}
	rescue => e 

	end 

	private

	def post server, path, args
		params = {headers: {'content-type'=>'application/json; charset=utf-8'}, query: args}
		uri = "http://#{server.ip}:#{server.port}/jiyu/admin/tools/#{path}"
		Rails.logger.debug "uri #{uri}"
		Rails.logger.debug "post #{args}"
		HTTParty.post(uri, params)
	end

	def sync server 
		#cc_file = Rails.root.join("lib","command_center.rb")
		#Net::SCP.upload!(server.ip, server.ssh_user, cc_file, "#{server.project_path}script/", ssh: {password: server.ssh_pwd})
	end

	def mail_config
		{
			cmd_name: 'mail',
			#邮件类型：normal 普通邮件，reward奖品邮件
			type: "normal",
			"name" => "管理员大大",
			"title" => "管理员邮件",
			"message" => "管理员大大"
		}
	end

	def send_mail server, hash
		config = mail_config.merge(hash).merge(params.permit(:name, :title, :message, :reward)).merge(server.tools_params)
	  send_cmd server, config
	end 

	def send_cmd server, config
	  dir = server.project_path
	  Rails.logger.debug("server.ip = #{server.ip}, server.ssh_user = #{server.ssh_user}")
	  msg = nil
	  Net::SSH.start(server.ip, server.ssh_user, password: server.ssh_pwd) do |ssh|
	  	Rails.logger.debug "ruby #{dir}script/command_center.rb \"#{config.to_query}\""
	  	msg = ssh.exec! "ruby #{dir}script/command_center.rb '#{config.to_query}'"
		end 
		msg || "send_cmd to #{server.ip} and nothing return"
	end 

	def web_console
	end

end 

class Hash
  def to_query
    CGI::escape(each.inject(""){|sum,item|sum+="#{item[0]}=#{item[1]}&";sum}.match(/^(.*)\&$/)[1])
  end
end
class String
  def to_params
    CGI::unescape(self).split("&").inject({}){|hash,item|arr=item.split("=");hash[arr[0]]=arr[1];hash}
  end
end
