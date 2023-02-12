class AddHourlyWorkerHasRemoved30MinToScanEvents < ActiveRecord::Migration[6.1]
  def up
    add_column :scan_events, :hourly_worker_has_removed_30_min, :boolean, default: false
    ScanEvent.all.each do |scan_event|
      if scan_event.hourly_worker_delta_time.present? && scan_event.hourly_worker_delta_time > ScanEvent::REMOVE_30MIN_AFTER.hours.to_i
        scan_event.update(hourly_worker_has_removed_30_min: true)
      end
    end
  end

  def down
    remove_column :scan_events, :hourly_worker_has_removed_30_min
  end

end
