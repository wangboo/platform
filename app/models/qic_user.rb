class QicUser
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username

  field :password

  field :token, default: ->{1.upto(32).collect{@@seed[rand(@@seed.size)]}.join}


  @@seed = (0..9).to_a + ('a'..'z').to_a + ('A'..'Z').to_a

  validates_presence_of :username, message: "您必须提供用户名"

  validates_presence_of :password, message: "您必须提供密码"

  validates_uniqueness_of :username, message: "该账号已经存在"

end
