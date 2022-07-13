class TimeStampsController < ApplicationController
  before_action :authenticate_user!
  before_action { @section = 'time_stamps' }

  # GET /time_stamps
  # GET /time_stamps.json
  def index
    @total_scan_events = ScanEvent.all.includes(:member).where(member: {is_hourly_worker: true}).where("hourly_worker_in IS true OR hourly_worker_out IS true")
    @scan_events = @total_scan_events.order(created_at: :desc).limit(30)
  end

  # POST /time_stamps/export
  require 'csv'
  def export
    @scan_events = ScanEvent.all.includes(:member).where(member: {is_hourly_worker: true}).where("hourly_worker_in IS true OR hourly_worker_out IS true").order(created_at: :desc)
    csv_data = CSV.generate do |csv|
      @scan_events.each_with_index do |scan_event, i|
        scan_event_hash = scan_event.attributes.slice(
          'created_at', 'hourly_worker_in', 'hourly_worker_out',
          'hourly_worker_delta_time', 'hourly_worker_monthly_time'
        )
        csv << scan_event_hash.keys.prepend('first_name', 'last_name', 'time_stamp') if i == 0
        csv << scan_event_hash.values.prepend(scan_event.member.first_name, scan_event.member.last_name, scan_event.created_at.to_i)
      end
    end
    send_data(csv_data.gsub('""', ''), type: 'text/csv', filename: "hourly_worker_scan_events_#{Time.now.to_i}.csv")
  end

end
