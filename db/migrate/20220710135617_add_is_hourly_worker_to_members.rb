class AddIsHourlyWorkerToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :is_hourly_worker, :boolean, default: false
  end
end
