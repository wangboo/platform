class ServerStatesController < ApplicationController
  
  before_action :find_server_state, only: [:update]

  def index
  	@server_states = ServerState.all.order("id asc")
  	@new_server_state = ServerState.new
  end

  def create
  	ServerState.create server_state_params
  	redirect_to server_states_path
  end

  def update
    @server_state.update server_state_params
    redirect_to server_states_path
  end

  def find_server_state
    @server_state = ServerState.find(params[:id])
  end

  def server_state_params
  	params.require("server_state").permit(:name, :desc, :show)
  end

end
