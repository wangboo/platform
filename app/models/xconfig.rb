class Xconfig

	def self.bgm_ip
		"http://203.195.148.216:9000"
	end

	def self.bgm_ac_url
		"#{self.bgm_ip}/#/ac"
	end

	def self.hide_pwd
		bgm_ip =~ /203.195.224.152/
	end

end
