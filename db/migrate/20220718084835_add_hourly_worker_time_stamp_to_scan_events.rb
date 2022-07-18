class AddHourlyWorkerTimeStampToScanEvents < ActiveRecord::Migration[6.1]
  def up
    add_column :scan_events, :hourly_worker_time_stamp, :datetime, precision: 6
    ScanEvent.all.each do |scan_event|
      if scan_event.hourly_worker_in || scan_event.hourly_worker_out
        scan_event.update(hourly_worker_time_stamp: scan_event.created_at)
      end
    end
  end

  def down
    remove_column :scan_events, :hourly_worker_time_stamp
  end

end
