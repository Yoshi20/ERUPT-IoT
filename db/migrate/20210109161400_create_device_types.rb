class CreateDeviceTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :device_types do |t|
      t.string :name, null: false, unique: true
      t.integer :number_of_buttons
    end
  end
end
