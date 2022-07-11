class TimeStampsController < ApplicationController
  before_action :authenticate_user!
  before_action { @section = 'time_stamps' }

  # GET /time_stamps
  # GET /time_stamps.json
  def index
    @scan_events = ScanEvent.all.includes(:member).where(member: {is_hourly_worker: true}).order(created_at: :desc).limit(10)
  end

end
