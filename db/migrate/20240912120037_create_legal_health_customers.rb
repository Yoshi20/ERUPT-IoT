class CreateLegalHealthCustomers < ActiveRecord::Migration[6.1]
  def change
    create_table :legal_health_customers do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
