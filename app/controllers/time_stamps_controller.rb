class TimeStampsController < ApplicationController
  before_action :authenticate_user!
  before_action { @section = 'time_stamps' }

  # GET /time_stamps
  # GET /time_stamps.json
  def index
    # raise params.inspect#blup
    @member_id = params[:member_filter]
    @work_month_id = params[:work_month_filter]
    @total_scan_events = ScanEvent.all.includes(:member).where(member: {is_hourly_worker: true}).where("hourly_worker_in IS true OR hourly_worker_out IS true")
    @total_scan_events = @total_scan_events.where(member: {id: @member_id}) if @member_id.present?
    @total_scan_events = @total_scan_events.where("hourly_worker_time_stamp >= ? AND hourly_worker_time_stamp <= ?", beginning_of_work_month_from_id(@work_month_id), end_of_work_month_from_id(@work_month_id)) if @work_month_id.present?
    @scan_events = @total_scan_events.order(hourly_worker_time_stamp: :desc)
    @scan_events = @scan_events.limit(30) unless @member_id.present? && @work_month_id.present?
  end

  # POST /time_stamps/export
  require 'csv'
  def export
    @member_id = params[:member_filter]
    @work_month_id = params[:work_month_filter]
    @scan_events = ScanEvent.all.includes(:member).where(member: {is_hourly_worker: true}).where("hourly_worker_in IS true OR hourly_worker_out IS true").order(hourly_worker_time_stamp: :desc)
    @scan_events = @scan_events.where(member: {id: @member_id}) if @member_id.present?
    @scan_events = @scan_events.where("hourly_worker_time_stamp >= ? AND hourly_worker_time_stamp <= ?", beginning_of_work_month_from_id(@work_month_id), end_of_work_month_from_id(@work_month_id)) if @work_month_id.present?
    csv_data = CSV.generate do |csv|
      @scan_events.each_with_index do |scan_event, i|
        wd = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'][scan_event.hourly_worker_time_stamp.localtime.wday]
        datetime = scan_event.hourly_worker_time_stamp.localtime.to_s(:custom_datetime)
        scan_event_hash = {
          time_stamp: "#{wd}, #{datetime}",
          first_name: scan_event.member.first_name,
          last_name: scan_event.member.last_name,
          hour_in: scan_event.hourly_worker_in ? scan_event.hourly_worker_time_stamp.localtime.to_s(:custom_datetime_hour) : nil,
          hour_out: scan_event.hourly_worker_out ? scan_event.hourly_worker_time_stamp.localtime.to_s(:custom_datetime_hour) : nil,
          delta_time_h: scan_event.hourly_worker_out ? (scan_event.hourly_worker_delta_time.to_f/3600).round(2) : nil,
          monthly_time_h: scan_event.hourly_worker_out ? (scan_event.hourly_worker_monthly_time.to_f/3600).round(2) : nil,
          removed_time_h: scan_event.hourly_worker_has_removed_30_min ? 0.5 : nil,
        }
        csv << scan_event_hash.keys if i == 0
        csv << scan_event_hash.values
      end
    end
    hourly_worker_name = @member_id.present? ? "#{Member.find(@member_id).first_name}s" : "hourly_worker"
    send_data(csv_data.gsub('""', ''), type: 'text/csv', filename: "#{hourly_worker_name}_time_stamps_#{Time.now.to_i}.csv")
  end

private

  def beginning_of_work_month_from_id(work_month_id)
    beginning_of_selected_month = Time.now.beginning_of_year + work_month_id.to_i.months
    beginning_of_selected_month - 1.month + 25.days
  end

  def end_of_work_month_from_id(work_month_id)
    beginning_of_selected_month = Time.now.beginning_of_year + work_month_id.to_i.months
    beginning_of_selected_month + 25.days - 1.second
  end

end
