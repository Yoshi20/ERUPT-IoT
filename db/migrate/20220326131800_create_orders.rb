class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :title
      t.string :text
      t.string :data
      t.boolean :acknowledged, default: false
      t.string :acknowledged_by
      t.datetime :acknowledged_at
      t.bigint :device_id
      t.timestamps
    end

    add_foreign_key :orders, :devices
  end
end
