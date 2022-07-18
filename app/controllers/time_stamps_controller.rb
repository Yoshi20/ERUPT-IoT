class TimeStampsController < ApplicationController
  before_action :authenticate_user!
  before_action { @section = 'time_stamps' }

  # GET /time_stamps
  # GET /time_stamps.json
  def index
    @total_scan_events = ScanEvent.all.includes(:member).where(member: {is_hourly_worker: true}).where("hourly_worker_in IS true OR hourly_worker_out IS true")
    @scan_events = @total_scan_events.order(hourly_worker_time_stamp: :desc).limit(30)
  end

  # POST /time_stamps/export
  require 'csv'
  def export
    @scan_events = ScanEvent.all.includes(:member).where(member: {is_hourly_worker: true}).where("hourly_worker_in IS true OR hourly_worker_out IS true").order(hourly_worker_time_stamp: :desc)
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
        }
        csv << scan_event_hash.keys if i == 0
        csv << scan_event_hash.values
      end
    end
    send_data(csv_data.gsub('""', ''), type: 'text/csv', filename: "hourly_worker_time_stamps_#{Time.now.to_i}.csv")
  end

end
