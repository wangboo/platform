class IapController < AppSideController

	def sandbox_url
		"https://sandbox.itunes.apple.com/verifyReceipt"
	end

	def production_url
		"https://buy.itunes.apple.com/verifyReceipt"
	end

	def success msg=nil
    Rails.logger.debug msg if msg
    #render json: 'success'
#    render json: {'-r':-1,'-m':msg}
   render json: '{"_r":"0","_m":"充值成功"}'
  end

  def fail msg=nil
    Rails.logger.error msg if msg
#    render json: 'fail'
    render json: '{"_r":"-1","_m":"充值失败"}'
  end

	def verify_pay
		data = Base64.decode64 params[:receipt]
		user_id, server_id = params[:userId], params[:serverId]
    platform_id = Server.find(server_id).platform_id
    sandbox = data.split("\n\t")[3].include?("Sandbox")
		url = if sandbox then sandbox_url else production_url end
		body = HTTParty.post(url, body: {"receipt-data" => params[:receipt]}.to_json).body
		hash = JSON.parse body
		return resp_app_f "receipt错误" unless hash["status"] == 0
		# 订单已经成功
    receipt = hash['receipt']
    logger.debug "return #{hash}"
    logger.debug "pruduct_id=#{receipt['product_id']}"
    logger.debug "000000-------#{/^.*\.(\d+)gold2$/.match(receipt["product_id"])}"
    charge = IOSChargeInfo.find_by(order_id: receipt['unique_identifier'])
		return resp_app_s("该订单已经充值成功，不再受理") if charge and charge.add_money == 1
    a = '-1';
	   if receipt["product_id"].include? 'monthcard2'
			a='9'
		#elsif rst = receipt["product_id"].scan(/^.*\.(\d+)gold$/).first
    elsif nil !=  /^.*\.(\d+)gold2$/.match(receipt["product_id"])
      #logger.debug "1-------#{$1}"
      mon = $1
			a = JiyuOrder.gold2product mon.to_i
      logger.debug "aa==#{JiyuOrder.gold2product $1}"
      logger.debug "a==#{a}"
		#elsif rst = receipt["product_id"].scan(/^.*\.(\d+)leaguer$/).first
    elsif nil != /^.*\.(\d+)leaguer2$/.match(receipt["product_id"])
      mon = $1
			a = JiyuOrder.day_product_mapping[mon.to_s] or '-1'
		else
			'-1'
		end
     product = a
     logger.debug "product=#{product}"
		return resp_app_f "找不到产品" if product == '-1'
		money = JiyuOrder.product_money_mapping[product]
		# 生成订单
		order = JiyuOrder.generate_order user_id, product, server_id, platform_id
		# def self.charge data, suc_func, fail_func
		payment = HashWithIndifferentAccess.new(
      order_id:           order.order_id,
      platform_order_id:  receipt['unique_identifier'],
      state:              true ,
      money:              money,
      params:             params.to_json
    )
		IOSChargeInfo.charge payment, proc{|m|success m}, proc{|m|fail m}
	end


end
