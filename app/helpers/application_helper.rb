module ApplicationHelper

	# 错误页面分页插件
	def error_page_padding cur_page, max_page
		str = %{
			<div class="col-md-12">
			<div class="col-md-4 col-md-offset-4">
			<ul class="pagination">
		}
		if cur_page == 1
			str << %{<li class="disabled"><a href="#">首页</a></li>}
			str << %{<li class="disabled"><a href="#">上一页</a></li>}
		else
			str << %{<li><a href="err_app?cur_page=1">首页</a></li>}
			str << %{<li><a href="err_app?cur_page=#{cur_page-1}">上一页</a></li>}
		end
		if cur_page >= max_page
			str << %{<li class="disabled"><a href="#">下一页</a></li>}
			str << %{<li class="disabled"><a href="#">尾页</a></li>}
		else
			str << %{<li><a href="err_app?cur_page=#{cur_page + 1}">下一页</a></li>}
			str << %{<li><a href="err_app?cur_page=#{max_page}">尾页</a></li>}
		end
		str << "</ul></div>"
		str << %{
			<div class="input-group col-md-3" style="margin-top:20px">
			  <span class="input-group-addon">跳转(当前#{cur_page}页, 最大#{max_page})</span>
			  <input type="text" class="form-control" id="jump_input">
				<a class="input-group-addon btn btn-default" id="jump_to">跳转</a>
			</div>
		}
		# 
		# <button class="btn btn-default input-group-addon" id="jump_to">跳转</button>		
		str << %{
			<script type="text/javascript">
				$(function(){
					$("#jump_to").click(function(){
						var num = $("#jump_input").val()
						var href = "/err_app?cur_page="+num;
						this.setAttribute("href", href);
					})
				})
			</script>
		}
		raw str
	end

end
