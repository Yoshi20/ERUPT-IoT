class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :update, :destroy]
  before_action { @section = 'orders' }

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.where(acknowledged: true).order(created_at: :desc)
  end

  # GET /orders_fullscreen
  def index_fullscreen
    @orders = Order.where(acknowledged: false)
    render "index_fullscreen", layout: "application_fullscreen"
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    respond_to do |format|
      format.js {render partial: 'single_order', locals: {order: @order}, layout: false}
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      @order.acknowledge(current_user) if order_params[:acknowledged]
      if @order.save
        format.html { redirect_to orders_fullscreen_url, notice: t('flash.notice.updating_order') }
        format.json { render json: {order: @order}, status: :ok }
      else
        format.html { redirect_to orders_fullscreen_url, notice: t('flash.alert.updating_order') }
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
        format.html { redirect_to orders_url, notice: t('flash.alert.deleting_order') }
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
