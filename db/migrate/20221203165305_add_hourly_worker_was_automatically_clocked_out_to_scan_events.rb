class AddHourlyWorkerWasAutomaticallyClockedOutToScanEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :scan_events, :hourly_worker_was_automatically_clocked_out, :boolean, default: false
  end
end
