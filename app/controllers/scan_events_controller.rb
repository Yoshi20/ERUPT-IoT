require "uri"
require "net/http"
require 'pusher/push_notifications'

class ScanEventsController < ApplicationController
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_action :authenticate_user!, only: [:index]
  skip_before_action :authenticate_user!, only: [:create]
  before_action :set_scan_event, only: [:show, :update, :destroy]
  before_action { @section = 'scan_events' }

  # GET /scan_events
  # GET /scan_events.json
  def index
    @total_scan_events = ScanEvent.where.not(member_id: nil)
    @scan_events = @total_scan_events.order(created_at: :desc).limit(10)
    @total_scan_events_no_member = ScanEvent.no_member
    @scan_events_no_member = @total_scan_events_no_member.order(created_at: :desc).limit(10)
  end

  def show
    respond_to do |format|
      format.html {render 'show'}
      format.js {render partial: 'scan_event', locals: {scan_event: @scan_event, layout: false}}
    end
  end

  # POST /scan_events
  # POST /scan_events.json
  def create
    post_body = params.except(:controller, :action, :scan_event)
    member = Member.find_by(card_id: params[:UID])
    scan_event = nil
    if member.present?
      member_abo_types = member.abo_types.active.map{|at| at.name}.join(' ')
      scan_event = ScanEvent.create(member_id: member.id, post_body: post_body, abo_types: member_abo_types, card_id: params[:UID])
      # get data from ggLeap if present
      if member.ggleap_uuid.present?
        jwt = Request::ggleap_auth
        ggleap_user = Request::ggleap_user(jwt, member.ggleap_uuid)
        member.magma_coins = ggleap_user["Balance"]
        member.save
      end
      # send data via ws
      post_data = {
        first_name: member.first_name,
        magma_coins: member.magma_coins,
        abo_types: member_abo_types
      }
      WifiDisplay.all.each do |disp|
        ActionCable.server.broadcast(
          disp.name,
          post_data
        )
      end
      # push notification
      data = {
        web: {
          notification: {
            title: 'ScanEvent',
            body: "#{member.first_name} #{member.last_name}",
            icon: request.base_url + '/' + ActionController::Base.helpers.asset_path("logo.jpg"),
            deep_link: (member.ggleap_uuid.present? ? "https://admin.ggleap.com/shop?user=#{member.ggleap_uuid}" : "https://admin.ggleap.com/users"),
            hide_notification_if_site_has_focus: false,
          }
        }
      }
      Pusher::PushNotifications.publish_to_interests(interests: ['scan_events'], payload: data)
    else
      # no member yet -> create "empty" ScanEvent
      scan_event = ScanEvent.create(post_body: post_body, card_id: params[:UID])
    end
    respond_to do |format|
      if scan_event.present?
        ActionCable.server.broadcast('ScanEventsChannel', scan_event)
        format.html { render plain: "OK", status: :ok }
      else
        format.html { head :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scan_events/1
  # PATCH/PUT /scan_events/1.json
  def update
    respond_to do |format|
      if @scan_event.card_id.present?
        member = Member.find(scan_event_params[:member_id]) if scan_event_params[:member_id].present?
        if member.present? && member.update(card_id: @scan_event.card_id)
          if @scan_event.update(member_id: scan_event_params[:member_id])
            # update also all scan_events with the same card_id
            ScanEvent.where(card_id: @scan_event.card_id).each do |se|
              se.update(member_id: scan_event_params[:member_id]);
            end
            format.html { redirect_to scan_events_url, notice: t('flash.notice.updating_scan_event') }
            format.json { render :show, status: :ok, location: @scan_event }
          else
            format.html { render :show, alert: t('flash.alert.updating_scan_event') }
            format.json { render json: @scan_event.errors, status: :unprocessable_entity }
          end
        else
          format.html { render :show, alert: t('flash.alert.updating_member') }
          format.json { render json: member.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :show, alert: t('flash.alert.no_card_id') }
        format.json { render json: { alert: t('flash.alert.no_card_id') }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scan_events/1
  # DELETE /scan_events/1.json
  def destroy
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scan_event
      @scan_event = ScanEvent.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def scan_event_params
      params.require(:scan_event).permit(:member_id)
    end

end
