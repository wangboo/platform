module PlatformHelper

	def platform_check_box_group_tag
		all = Platform.all.order("id asc")
		str = ''
		all.each do |platform|
			str += '<div class="col-lg-3 col-md-3"><div class="input-group"><span class="input-group-addon">'
			str += "<input type='checkbox' id='ppp_#{platform.mask}' name='active_batch[platform_ids][]' value='#{platform.id}' class='control-label'></span>"
			str += "<label type='text' for='ppp_#{platform.mask}' class='form-control'>#{platform.name}</label></div></div>"
		end
		raw str
	end

end
