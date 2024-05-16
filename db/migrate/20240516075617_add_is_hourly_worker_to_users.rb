class AddIsHourlyWorkerToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :is_hourly_worker, :boolean, default: false
  end
end
