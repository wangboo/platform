# 定时任务
class HttpJob 
	include Mongoid::Document
	include Mongoid::Timestamps
	# 发送url
	field :url
	# 发送方式
	field :http_type, default: "GET"
	# 定时数据
	field :data, type: Hash, default: {}
	# 触发时间
	field :trigger_time
	# 是否触发
	field :trigger, type: Boolean, default: false 
	# 执行结果
	field :result

	field :exception_his, type: Array, default: []

	def should_trigger
		Time.now >= trigger_time
	end

	def do_it
		begin
			self.result = if http_type == 'POST'
				HTTParty.post(url, body: data).body
			else
				HTTParty.get(url, body: data).body
			end
			self.trigger = true
			self.save
		rescue => e 
			self.exception_his << e.message
			self.save 
		end
	end

	def self.tryDoJob
		HttpJob.where(trigger: false).select(&:should_trigger).each do |job|
			job.do_it
		end
	end

end