class GgleapProductsController < ApplicationController
  before_action :authenticate_user!, except: [:index_for_iframe]
  before_action :get_products, only: [:index, :index_for_iframe]
  before_action { @section = 'ggleap_products' }

  # GET /ggleap_products
  def index
  end

  # GET /ggleap_products_for_iframe
  def index_for_iframe
    response.headers["X-FRAME-OPTIONS"] = "ALLOWALL"  # prevent CORS issues
    render "index", layout: "for_iframe"
  end

  # GET /ggleap_products_refresh
  def refresh
    Rails.cache.delete("ggleap_products")
    redirect_to ggleap_products_path
  end

private

  def get_products
    jwt = Request::ggleap_auth
    ggleap_products = Request::ggleap_products(jwt)
    @ggleap_products = []
    ggleap_products.each do |p|
      # filter some products
      if !p['IsHiddenFromInventory'] && p['Price'] < 100 && !p['Name'].include?('Coins') && !p['Name'].include?('CHF')
        @ggleap_products << p
      end
    end
    # handle search parameter
    if params[:search].present?
      @ggleap_products.select! { |p| p['Name'].include?(params[:search]) }
      if @ggleap_products.empty?
        flash.now[:alert] = t('flash.alert.search_ggleap_products')
      end
    end
    # sort
    @ggleap_products = @ggleap_products.sort_by { |product| product["Name"] }
  end

end
