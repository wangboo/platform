class RewardsController < ApplicationController

	before_action :find_reward, only: [:update, :delete]

  def create
  	Reward.create reward_params
  	redirect_to rewards_path
  end

  def index
  	@rewards = Reward.all.order('id asc')
  	@new_reward = Reward.new
  end

  def delete
  end

  def update
  	@reward.update reward_params
  	redirect_to rewards_path
  end

  def reward_params
  	params.require('reward').permit(:name, :desc, :reward)
  end

  def find_reward
  	@reward = Reward.find params[:id]
  end

end
