class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :update, :destroy]
  before_action { @section = 'orders' }

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show

  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to orders_url, notice: t('flash.notice.updating_order') }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :show, alert: t('flash.alert.updating_order') }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    respond_to do |format|
      if @order.destroy
        format.html { redirect_to orders_url, notice: t('flash.notice.deleting_order') }
        format.json { head :no_content }
      else
        format.html { render :show, alert: t('flash.alert.deleting_order') }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.require(:order).permit(:acknowledged)
    end

end
