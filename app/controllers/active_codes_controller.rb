class ActiveCodesController < ApplicationController
  before_action :set_active_code, only: [:show, :edit, :update, :destroy]
  
  # GET /active_codes
  # GET /active_codes.json
  def index
    @active_codes = ActiveCode.all
  end

  # GET /active_codes/1
  # GET /active_codes/1.json
  def show
  end

  # GET /active_codes/new
  def new
    @active_code = ActiveCode.new
  end

  # GET /active_codes/1/edit
  def edit
  end

  # POST /active_codes
  # POST /active_codes.json
  def create
    @active_code = ActiveCode.new(active_code_params)

    respond_to do |format|
      if @active_code.save
        format.html { redirect_to @active_code, notice: 'Active code was successfully created.' }
        format.json { render :show, status: :created, location: @active_code }
      else
        format.html { render :new }
        format.json { render json: @active_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /active_codes/1
  # PATCH/PUT /active_codes/1.json
  def update
    respond_to do |format|
      if @active_code.update(active_code_params)
        format.html { redirect_to @active_code, notice: 'Active code was successfully updated.' }
        format.json { render :show, status: :ok, location: @active_code }
      else
        format.html { render :edit }
        format.json { render json: @active_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /active_codes/1
  # DELETE /active_codes/1.json
  def destroy
    @active_code.destroy
    respond_to do |format|
      format.html { redirect_to active_codes_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_active_code
      @active_code = ActiveCode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def active_code_params
      params[:active_code].permit
    end
end
