
class GmAccount
	include Mongoid::Document

	field :username 
	field :password
	field :login_at, type: Time

	validates_uniqueness_of :username

end