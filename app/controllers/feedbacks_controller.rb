include Recaptcha::Adapters::ViewMethods
include Recaptcha::Adapters::ControllerMethods

class FeedbacksController < ApplicationController
  before_action :authenticate_user!, except: [:new_extern, :create_extern, :success_extern]
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]
  before_action { @section = 'feedbacks' }

  # GET /feedbacks
  # GET /feedbacks.json
  def index
    @feedbacks = Feedback.all.order(created_at: :desc)
    @location_rating_average = @feedbacks.map(&:location_rating).sum.to_f/@feedbacks.count
    @event_rating_average = @feedbacks.map(&:event_rating).sum.to_f/@feedbacks.count
  end

  # GET /feedbacks/1
  # GET /feedbacks/1.json
  def show
  end

  # GET /feedbacks/new
  def new
    @feedback = Feedback.new
  end

  # GET /feedbacks/extern/new
  def new_extern
    @feedback = Feedback.new
    render "new_extern", layout: "application_extern"
  end

  # GET /feedbacks/1/edit
  def edit
  end

  # POST /feedbacks
  # POST /feedbacks.json
  def create
    @feedback = Feedback.new(feedback_params)
    respond_to do |format|
      if @feedback.save
        format.html { redirect_to current_user.present? ? @feedback : feedbacks_path, notice: t('flash.notice.creating_feedback') }
        format.json { render :show, status: :created, location: @feedback }
      else
        format.html { render :new, alert: t('flash.alert.creating_feedback') }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /feedbacks/extern
  def create_extern
    @feedback = Feedback.new(feedback_params)
    respond_to do |format|
      if verify_recaptcha && @feedback.save
        format.html { redirect_to feedbacks_extern_success_path, layout: "application_extern" }
        format.json { render :show, status: :created, location: @feedback }
      else
        format.html { render :new_extern, layout: "application_extern", alert: t('flash.alert.creating_feedback') }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /feedbacks/extern/success
  def success_extern
    render "success_extern", layout: "application_extern"
  end

  # PATCH/PUT /feedbacks/1
  # PATCH/PUT /feedbacks/1.json
  def update
    respond_to do |format|
      if @feedback.update(feedback_params)
        format.html { redirect_to feedbacks_url, notice: t('flash.notice.updating_feedback') }
        format.json { render :show, status: :ok, location: @feedback }
      else
        format.html { render :edit, alert: t('flash.alert.updating_feedback') }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.json
  def destroy
    respond_to do |format|
      if @feedback.destroy
        format.html { redirect_to feedbacks_url, notice: t('flash.notice.deleting_feedback') }
        format.json { head :no_content }
      else
        format.html { render :show, alert: t('flash.alert.deleting_feedback') }
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feedback
      @feedback = Feedback.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def feedback_params
      params.require(:feedback).permit(:location_rating, :location_good,
        :location_bad, :location_missing, :location_will_recommend,
        :event_rating, :event_good, :event_bad, :event_missing,
        :event_will_recommend, :read)
    end

end
