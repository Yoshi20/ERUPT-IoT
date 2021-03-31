class CreateScanEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :scan_events do |t|
      t.bigint :member_id
      t.timestamps
    end
    add_foreign_key :scan_events, :members
  end
end
