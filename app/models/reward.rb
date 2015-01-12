class Reward
  include Mongoid::Document
  include Mongoid::Timestamps
  #奖励
  field :reward
  #奖励名
  field :name
  #奖励描述
  field :desc
  
  validates_presence_of :reward, message: "必须填写奖励内容"
    
end
