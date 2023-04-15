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
    @overall_rating_average = @feedbacks.map(&:overall_rating).sum.to_f/@feedbacks.count
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
        format.html { redirect_to current_user.present? ? feedback_path(@feedback) : feedbacks_path, notice: t('flash.notice.creating_feedback') }
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

  # POST /feedbacks/export
  require 'csv'
  def export
    @feedbacks = Feedback.all.order(created_at: :desc)
    csv_data = CSV.generate do |csv|
      @feedbacks.each_with_index do |feedback, i|
        wd = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'][feedback.created_at.localtime.wday]
        datetime = feedback.created_at.localtime.to_s(:custom_datetime)
        feedback_hash = {
          created_at: "#{wd}, #{datetime}",
          read: feedback.read,
          overall_rating: feedback.overall_rating,
          service_rating: feedback.service_rating,
          ambient_rating: feedback.ambient_rating,
          how_often_do_you_visit: feedback.how_often_do_you_visit,
          what_to_improve: feedback.what_to_improve,
          what_to_keep: feedback.what_to_keep,
          console_rating: feedback.console_rating,
          console_comment: feedback.console_comment,
          pc_rating: feedback.pc_rating,
          pc_comment: feedback.pc_comment,
          karaoke_rating: feedback.karaoke_rating,
          karaoke_comment: feedback.karaoke_comment,
          board_game_rating: feedback.board_game_rating,
          board_game_comment: feedback.board_game_comment,
          offer_rating: feedback.offer_rating,
          offer_comment: feedback.offer_comment,
        }
        csv << feedback_hash.keys if i == 0
        csv << feedback_hash.values
      end
    end
    send_data(csv_data.gsub('""', ''), type: 'text/csv', filename: "feedback_#{Time.now.to_i}.csv")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feedback
      @feedback = Feedback.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def feedback_params
      params.require(:feedback).permit(:overall_rating, :service_rating,
        :ambient_rating, :how_often_do_you_visit, :what_to_improve,
        :what_to_keep, :console_rating, :console_comment, :pc_rating,
        :pc_comment, :karaoke_rating, :karaoke_comment, :board_game_rating,
        :board_game_comment, :offer_rating, :offer_comment, :read,)
    end

end
