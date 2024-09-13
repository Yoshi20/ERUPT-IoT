class CreateLegalHealthTopics < ActiveRecord::Migration[6.1]
  def change
    create_table :legal_health_topics do |t|
      t.string :name, null: false
      t.float :weighting, null: false

      t.timestamps
    end
  end
end
