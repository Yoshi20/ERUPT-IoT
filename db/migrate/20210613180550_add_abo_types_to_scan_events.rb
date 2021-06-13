class AddAboTypesToScanEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :scan_events, :abo_types, :string

  end
end
