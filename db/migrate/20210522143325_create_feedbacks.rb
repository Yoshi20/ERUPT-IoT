class CreateFeedbacks < ActiveRecord::Migration[6.1]
  def change
    create_table :feedbacks do |t|
      t.integer :location_rating, null: false
      t.string :location_good
      t.string :location_bad
      t.string :location_missing
      t.boolean :location_will_recommend
      t.integer :event_rating, null: false
      t.string :event_good
      t.string :event_bad
      t.string :event_missing
      t.boolean :event_will_recommend
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
