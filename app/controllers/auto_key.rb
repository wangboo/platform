class AutoKey
	include Mongoid::Document
	field :table_name
	field :key_name
	field :value

	class << self
		def next_id table, key="id"
			key = AutoKey.find_or_create_by(table_name: table, key_name: key) do |a|
				a.value = 0
			end
			key.value += 1
			key.save
			key.value
		end
	end 
end