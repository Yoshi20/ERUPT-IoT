class TimeStampsController < ApplicationController
  before_action :authenticate_user!
  before_action { @section = 'time_stamps' }

  # GET /time_stamps
  # GET /time_stamps.json
  def index
    @total_scan_events = ScanEvent.all.includes(:member).where(member: {is_hourly_worker: true})
    @scan_events = @total_scan_events.order(created_at: :desc).limit(20)
  end

end
