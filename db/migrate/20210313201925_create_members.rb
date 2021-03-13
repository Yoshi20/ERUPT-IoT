class CreateMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :members do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false, unique: true
      t.datetime :birthdate
      t.string :mobile_number
      t.string :gender
      t.string :canton
      t.text :comment
      t.boolean :wants_newsletter_emails
      t.boolean :wants_event_emails
      t.string :card_id, null: false, unique: true
      t.float :magma_coins
      t.datetime :expiration_date
      t.integer :number_of_scans

      t.timestamps
    end
  end
end
