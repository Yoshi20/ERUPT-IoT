class AddHourlyWorkerInToScanEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :scan_events, :hourly_worker_in, :boolean, default: false
    add_column :scan_events, :hourly_worker_out, :boolean, default: false
    add_column :scan_events, :hourly_worker_delta_time, :bigint
    add_column :scan_events, :hourly_worker_monthly_time, :bigint
  end
end
