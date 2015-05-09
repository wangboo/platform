class ActiveBatchesController < ApplicationController
  before_action :set_active_batch, only: [:show, :edit, :update, :destroy, :download]
  before_action :set_active_batches

  # GET /active_batches
  # GET /active_batches.json
  def index
    if @active_batches.first
      @active_batch = @active_batches.first
      render action: :show
    else
      @new_active_batch = ActiveBatch.new
      render action: :new
    end
  end

  # GET /active_batches/1
  # GET /active_batches/1.json
  def show
  end

  # GET /active_batches/new
  def new
    @new_active_batch = ActiveBatch.new
  end

  # GET /active_batches/1/edit
  def edit
  end

  # POST /active_batches
  # POST /active_batches.json
  def create
    params[:active_batch][:is_muti] = (params[:active_batch][:is_muti] == "on")
    param = active_batch_params
    size = params[:size].to_i
    # params[:all_platform] = params[:all_platform]=='on' ? true : false
    param['all_platform'] = param['all_platform']=='on' ? true : false
    param['begin_time'] = DateTime.strptime(param['begin_time'], "%Y-%m-%d")
    param['end_time'] = DateTime.strptime(param['end_time'], "%Y-%m-%d")
    Rails.logger.debug "param = #{param}"
    active_batch = ActiveBatch.create(param)
    active_batch.generate_codes size
    redirect_to active_batch_path(active_batch)
  end

  # PATCH/PUT /active_batches/1
  # PATCH/PUT /active_batches/1.json
  def update

  end

  # DELETE /active_batches/1
  # DELETE /active_batches/1.json
  def destroy
    active_batch = ActiveBatch.find(params[:active_batch][:id])
    active_batch.destroy
    redirect_to "/active_batches"
  end

  def download
    all = ActiveCode.where(active_batch_id: params[:id]).pluck(:code)
    render plain: all.join("\n")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_active_batch
      @active_batch = ActiveBatch.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def active_batch_params
      params.require(:active_batch).permit(:all_platform, :desc, :name, :begin_time, :end_time, :reward_id, :active_type_id, :is_muti, :lim_times, platform_ids: [])
    end

    def set_active_batches
      @active_batches = ActiveBatch.all.order("id asc")
    end

end
