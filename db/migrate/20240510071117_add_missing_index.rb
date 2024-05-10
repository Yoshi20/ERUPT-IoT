class AddMissingIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :devices, :device_type_id
    add_index :devices, :user_id
    add_index :orders, :device_id
    add_index :scan_events, :member_id
  end
end
