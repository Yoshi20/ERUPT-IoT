class CreateLegalHealthParams < ActiveRecord::Migration[6.1]
  def change
    create_table :legal_health_params do |t|
      t.string :desciption, null: false
      t.bigint :legal_health_topic_id

      t.timestamps
    end
    add_foreign_key :legal_health_params, :legal_health_topics
    add_index :legal_health_params, :legal_health_topic_id
  end
end
