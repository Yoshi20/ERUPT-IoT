class AddExpirationDateToAboTypesMembers < ActiveRecord::Migration[6.1]

  def up
    add_column :abo_types_members, :id, :primary_key
    add_column :abo_types_members, :expiration_date, :datetime
    add_column :abo_types_members, :created_at, :datetime
    add_column :abo_types_members, :updated_at, :datetime
    AboTypesMember.all.each_with_index do |atm, i|
      atm.id = i+1
      created_at = Member.find(atm.member_id).created_at
      atm.expiration_date = created_at + 1.year
      atm.created_at = created_at
      atm.updated_at = created_at
      atm.save!
    end
    change_column :abo_types_members, :expiration_date, :datetime, precision: 6, null: false
    change_column :abo_types_members, :created_at, :datetime, precision: 6, null: false
    change_column :abo_types_members, :updated_at, :datetime, precision: 6, null: false
  end

  def down
    remove_column :abo_types_members, :id
    remove_column :abo_types_members, :expiration_date
    remove_column :abo_types_members, :created_at
    remove_column :abo_types_members, :updated_at
  end

end
