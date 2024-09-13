class LegalHealthParamsController < ApplicationController
  skip_before_action :authenticate_user! #blup
  before_action :set_legal_health_param, only: %i[ show edit update destroy ]

  # GET /legal_health_params or /legal_health_params.json
  def index
    @legal_health_params = LegalHealthParam.all
  end

  # GET /legal_health_params/1 or /legal_health_params/1.json
  def show
    redirect_to legal_health_params_path
  end

  # GET /legal_health_params/new
  def new
    @legal_health_param = LegalHealthParam.new
  end

  # GET /legal_health_params/1/edit
  def edit
  end

  # POST /legal_health_params or /legal_health_params.json
  def create
    @legal_health_param = LegalHealthParam.new(legal_health_param_params)

    respond_to do |format|
      if @legal_health_param.save
        format.html { redirect_to legal_health_param_url(@legal_health_param), notice: "Legal health param was successfully created." }
        format.json { render :show, status: :created, location: @legal_health_param }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @legal_health_param.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /legal_health_params/1 or /legal_health_params/1.json
  def update
    respond_to do |format|
      if @legal_health_param.update(legal_health_param_params)
        format.html { redirect_to legal_health_param_url(@legal_health_param), notice: "Legal health param was successfully updated." }
        format.json { render :show, status: :ok, location: @legal_health_param }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @legal_health_param.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /legal_health_params/1 or /legal_health_params/1.json
  def destroy
    @legal_health_param.destroy

    respond_to do |format|
      format.html { redirect_to legal_health_params_url, notice: "Legal health param was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_legal_health_param
      @legal_health_param = LegalHealthParam.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def legal_health_param_params
      params.require(:legal_health_param).permit(:description, :legal_health_topic_id)
    end
end
