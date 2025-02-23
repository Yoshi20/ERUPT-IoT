class CreateLegalHealthEvals < ActiveRecord::Migration[6.1]
  def change
    create_table :legal_health_evals do |t|
      t.integer :value, null: false
      t.bigint :legal_health_param_id
      t.bigint :legal_health_customer_id

      t.timestamps
    end
    add_foreign_key :legal_health_evals, :legal_health_params
    add_index :legal_health_evals, :legal_health_param_id
    add_foreign_key :legal_health_evals, :legal_health_customers
    add_index :legal_health_evals, :legal_health_customer_id
  end
end
