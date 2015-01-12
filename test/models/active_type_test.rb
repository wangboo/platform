require 'test_helper'

class ActiveTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  Mongoid.load!("config/mongoid.yml")
  
  def test_add_base
    ActiveType.create(name: "官方奖励包", val: 0)
    ActiveType.create(name: "91大礼包", val: 1)
    ActiveType.create(name: "百度大礼包", val: 2)
    ActiveType.create(name: "天上掉馅饼", val: 3)
    ActiveType.create(name: "豪华套餐包", val: 4)
    assert_equal ActiveType.all.size, 5
  end
  
  
end
