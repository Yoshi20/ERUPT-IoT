class ScanEventsController < ApplicationController
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_action :authenticate_user!, only: [:index]
  skip_before_action :authenticate_user!, only: [:create]
  before_action { @section = 'scan_events' }

  # GET /scan_events
  # GET /scan_events.json
  def index
    @scan_events = ScanEvent.where("member_id != NULL").order(created_at: :desc)
    @scan_events_no_member = ScanEvent.where(member_id: nil).order(created_at: :desc)
  end

  # POST /scan_events
  # POST /scan_events.json
  def create
    post_body = params.except(:controller, :action, :scan_event)
    member = Member.find_by(card_id: params[:card_id])
    scan_event = nil
    if member.present?
      scan_event = ScanEvent.create(member_id: member.id, post_body: post_body)
    else
      # no member yet -> create "empty" ScanEvent
      scan_event = ScanEvent.create(post_body: post_body)
    end
    if scan_event.present?
      render json: {}, status: :created
    else
      render json: {error: "couldn't create scan_event"}, status: :unprocessable_entity
    end
  end

  # DELETE /scan_events/1
  # DELETE /scan_events/1.json
  def destroy
    @scan_event = ScanEvent.find(params[:id])
    respond_to do |format|
      if @scan_event.destroy
        format.html { redirect_to scan_events_url, notice: t('flash.notice.deleting_scan_event') }
        format.json { head :no_content }
      else
        format.html { render :show, alert: t('flash.alert.deleting_scan_event') }
        format.json { render json: @scan_event.errors, status: :unprocessable_entity }
      end
    end
  end

end
