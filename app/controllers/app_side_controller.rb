# 前端App Controller
class AppSideController < ActionController::Base

	# 应答app端成功
	def resp_app_s *data
		resp = resp_pkg
		if data.size > 0
			if data[0].is_a? String
				resp[:_m] = data[0]
				resp.merge!(data[1]) if data.size > 1
			else
				resp.merge!(data[0])
			end
		end
		resp_app(resp)
	end

	# 应答app端失败
	def resp_app_f data=nil
		resp = resp_pkg(data)
		resp[:_r] = "1"
		resp_app(resp)
	end

 # 应答app端，默认成功
	def resp_app data={}
		render json: data
	end

	# 应答报文
	def resp_pkg msg=nil
		if msg
			{_r: "0", _m: msg}
		else
			{_r: "0", _m: ""}
		end
	end

end