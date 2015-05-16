class ActiveCode
  include Mongoid::Document
  include Mongoid::Timestamps
  #兑换码
  field :code, default: ->{16.times.map{rand(10)}.join}
  #是否被使用标志
  field :use_flag, type: Mongoid::Boolean, default: false
  # 已经使用过的次数
  field :times
  #兑换人
  belongs_to :server_user
  #所属批次
  belongs_to :active_batch

end

