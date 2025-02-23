class LegalHealthEvalsController < ApplicationController
  skip_before_action :authenticate_user! #blup
  before_action :set_legal_health_eval, only: %i[ show edit update destroy ]

  # GET /legal_health_evals or /legal_health_evals.json
  def index
    @legal_health_evals = LegalHealthEval.all
  end

  # GET /legal_health_evals/1 or /legal_health_evals/1.json
  def show
    redirect_to legal_health_evals_path
  end

  # GET /legal_health_evals/new
  def new
    @legal_health_eval = LegalHealthEval.new
  end

  # GET /legal_health_evals/1/edit
  def edit
  end

  # POST /legal_health_evals or /legal_health_evals.json
  def create
    @legal_health_eval = LegalHealthEval.new(legal_health_eval_params)

    respond_to do |format|
      if @legal_health_eval.save
        # format.html { redirect_to legal_health_eval_url(@legal_health_eval), notice: "Legal health eval was successfully created." }
        format.html { redirect_to edit_legal_health_score_path(customer_id: @legal_health_eval.legal_health_customer_id), notice: "Legal health eval was successfully created." }
        format.json { render :show, status: :created, location: @legal_health_eval }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @legal_health_eval.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /legal_health_evals/1 or /legal_health_evals/1.json
  def update
    respond_to do |format|
      if @legal_health_eval.update(legal_health_eval_params)
        # format.html { redirect_to legal_health_eval_url(@legal_health_eval), notice: "Legal health eval was successfully updated." }
        format.html { redirect_to edit_legal_health_score_path(customer_id: @legal_health_eval.legal_health_customer_id), notice: "Legal health eval was successfully updated." }
        format.json { render :show, status: :ok, location: @legal_health_eval }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @legal_health_eval.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /legal_health_evals/1 or /legal_health_evals/1.json
  def destroy
    @legal_health_eval.destroy

    respond_to do |format|
      format.html { redirect_to legal_health_evals_url, notice: "Legal health eval was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_legal_health_eval
      @legal_health_eval = LegalHealthEval.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def legal_health_eval_params
      params.require(:legal_health_eval).permit(:value, :legal_health_param_id, :legal_health_customer_id)
    end
end
