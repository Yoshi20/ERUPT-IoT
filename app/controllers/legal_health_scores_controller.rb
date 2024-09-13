class LegalHealthScoresController < ApplicationController
  skip_before_action :authenticate_user! #blup

  # GET /legal_health_scores or /legal_health_scores.json
  def index
    @legal_health_customers = LegalHealthCustomer.all
  end

  # GET /legal_health_scores/1
  def show
    @customer = LegalHealthCustomer.find(params[:customer_id])
    @legal_health_evals = @customer.legal_health_evals
    @legal_health_topics = LegalHealthTopic.all.includes(:legal_health_params, legal_health_params: :legal_health_evals)
  end

  # GET /legal_health_scores/1/edit
  def edit
    @customer = LegalHealthCustomer.find(params[:customer_id])
    @legal_health_evals = @customer.legal_health_evals
    @legal_health_topics = LegalHealthTopic.all.includes(:legal_health_params, legal_health_params: :legal_health_evals)
  end

end
