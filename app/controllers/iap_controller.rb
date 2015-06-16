class IapController < AppSideController

	def sandbox_url
		"https://sandbox.itunes.apple.com/verifyReceipt"
	end

	def production_url
		"https://buy.itunes.apple.com/verifyReceipt"
	end

	def success msg=nil
    Rails.logger.debug msg if msg
    render json: 'success'
  end

  def fail msg=nil
    Rails.logger.error msg if msg
    render json: 'fail'
  end

	def verify_pay
		data = Base64.decode params[:receipt]
		user_id, server_id, platform_id = params[:userId], params[:serverId], params[:platform]
		url = if data["environment"] == 'Sandbox' then sandbox_url or production_url end 
		body = HTTParty.post(url, body: {"receipt-data" => params[:receipt]}.to_json).body
		hash = JSON.pase body
		return resp_app_f "receipt错误" unless hash["status"] == 0
		# 订单已经成功
		return resp_app_s if charge and charge.add_money == 1
		product = if body["product_id"] == 'com.jiyu.xqj.monthcard' 
			'9'
		elsif rst = body["product_id"].scan(/^com\.jiyu\.xqj\.(\d+)gold$/).first
			gold2product rst.first
		else
			'-1'
		end
		return resp_app_f "找不到产品" if product == '-1'
		money = JiyuOrder.product_money_mapping[product]
		# 生成订单
		order = JiyuOrder.generate_order user_id, product, server_id, platform_id
		# def self.charge data, suc_func, fail_func
		payment = HashWithIndifferentAccess.new(
      order_id:           order.order_id,
      platform_order_id:  hash['unique_identifier'],
      state:              true ,
      money:              money,
      params:             params.to_json
    )
		IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
	end


end