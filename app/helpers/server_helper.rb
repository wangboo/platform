module ServerHelper

	def work_state_select_tag work_state=0, id="server[work_state]"
		str = %(<select class="form-control" id="#{id}" name=server[work_state]><option value="0")
		str << ' selected' if work_state == 0
		str << '>运行中</option>'
		str << '<option value="1"'
		str << ' selected' if work_state == 1
		str << '>维护中</option>'
		str << '<option value="2"'
		str << ' selected' if work_state == 2
		str << '>已关闭</option></select>'
		raw str
	end

	def work_state_name val
		work_state = if val.is_a? Server
			val.work_state 
		else
			val
		end
		case work_state
		when 0
			raw '工作中'
		when 1
			raw '维护中'
		when 2
			raw '已关闭'
		end
	end

end
