class CreateWifiDisplays < ActiveRecord::Migration[6.1]
  def change
    create_table :wifi_displays do |t|
      t.string :dns
      t.string :path
      t.string :ip
      t.timestamps
    end
  end
end
