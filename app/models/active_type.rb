class ActiveType
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name
  field :desc
  field :mask
  # 持有很多注册批次,当该类型删除时，对应批次都要删除
  has_many :active_batches, dependent: :destory

  validates_presence_of :name, :mask

end
