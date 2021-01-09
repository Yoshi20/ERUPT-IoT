class CreateDevices < ActiveRecord::Migration[6.1]
  def change
    create_table :devices do |t|
      t.string :name,        null: false
      t.string :dev_eui,     null: false
      t.string :app_eui
      t.string :app_key
      t.string :hw_version
      t.string :fw_version
      t.integer :battery
      t.datetime :last_time_seen
      t.timestamps
    end
    add_column :devices, :device_type_id, :bigint
    add_foreign_key :devices, :device_types
    add_column :devices, :user_id, :bigint
    add_foreign_key :devices, :users
  end
end
