class LegalHealthCustomersController < ApplicationController
  skip_before_action :authenticate_user! #blup
  before_action :set_legal_health_customer, only: %i[ show edit update destroy ]

  # GET /legal_health_customers or /legal_health_customers.json
  def index
    @legal_health_customers = LegalHealthCustomer.all
  end

  # GET /legal_health_customers/1 or /legal_health_customers/1.json
  def show
    redirect_to legal_health_customers_path
  end

  # GET /legal_health_customers/new
  def new
    @legal_health_customer = LegalHealthCustomer.new
  end

  # GET /legal_health_customers/1/edit
  def edit
  end

  # POST /legal_health_customers or /legal_health_customers.json
  def create
    @legal_health_customer = LegalHealthCustomer.new(legal_health_customer_params)

    respond_to do |format|
      if @legal_health_customer.save
        format.html { redirect_to legal_health_customer_url(@legal_health_customer), notice: "Legal health customer was successfully created." }
        format.json { render :show, status: :created, location: @legal_health_customer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @legal_health_customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /legal_health_customers/1 or /legal_health_customers/1.json
  def update
    respond_to do |format|
      if @legal_health_customer.update(legal_health_customer_params)
        format.html { redirect_to legal_health_customer_url(@legal_health_customer), notice: "Legal health customer was successfully updated." }
        format.json { render :show, status: :ok, location: @legal_health_customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @legal_health_customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /legal_health_customers/1 or /legal_health_customers/1.json
  def destroy
    @legal_health_customer.destroy

    respond_to do |format|
      format.html { redirect_to legal_health_customers_url, notice: "Legal health customer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_legal_health_customer
      @legal_health_customer = LegalHealthCustomer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def legal_health_customer_params
      params.require(:legal_health_customer).permit(:name)
    end
end
