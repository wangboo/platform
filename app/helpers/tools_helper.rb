module ToolsHelper

	def base_form_field extra_fields=[]
		html = %Q{
			<div class="col-md-12 form-group">
				<label for="server" class="col-md-3 control-label">发放范围</label>
				<div class="col-md-7">
				<select id="server" class="form-control">
					<option value="all">--所有服务器--</option>
		}
		@servers.each do |s|
			html << "<option value='#{s.id}'>#{s.name}</option>"
		end
		html << "</select></div></div>"
		fields = ([
			['reward','奖励', '奖品标准格式，详情请问“戴维”'], 
			['title','标题', '邮件的标题'], 
			['content','内容','邮件显示的内容'], 
			['sender_name','发件人', '邮件显示的发件人']
		] + extra_fields)
		server_select + form_field_builder(fields)
	end

	# 服务器选择器
	def server_select
		html = %Q{
			<div class="col-md-12 form-group">
				<label for="server" class="col-md-3 control-label">发放范围</label>
				<div class="col-md-7">
				<select id="server" class="form-control">
					<option value="all">--所有服务器--</option>
		}
		@servers.each do |s|
			html << "<option value='#{s.id}'>#{s.name}</option>"
		end
		html << "</select></div></div>"
		raw html
	end

	def form_field_builder fields
		html = ""
		fields.each do |id,name, ph|
			html << %Q{
				<div class="form-group">
					<label class="control-label col-md-3" for="#{id}">#{name}</label>
					<div class="col-md-7">
						<input id="#{id}" class="form-control" placeholder="#{ph}">
					</div>
				</div>
			}
		end
		raw html
	end

	def notice_fields_builder
		fields = [
			['title', '公告标题', '公告标题'],
			['range', '活动范围', '公告显示活动范围'],
			['sort', '排序值', '排序越大显示在越前面']
		]
		form_field_builder fields
	end

	def scroll_field_builder
		fields = [
			['name', '发送者', '发送消息显示的发送者'],
			['message', '内容', '发送滚动消息的内容'],
		]
		form_field_builder fields
	end

	def mail_job_field
		raw %Q{
			<div class="form-group">
				<label class="col-md-3 control-label" for="job">定时任务</label>
				<div class="col-md-7">
					<div class="input-group">
			      <span class="input-group-addon">
			        <input type="checkbox" id="jobCheck">
			      </span>
			      <input type="text" class="form-control" id="job" disabled placeholder="年年年年-月月-日日 时时:分分">
			    </div><!-- /input-group -->
				</div>
			</div>
	}
	end

end
