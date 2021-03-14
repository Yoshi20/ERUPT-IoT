class CreateAboTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :abo_types do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_join_table :abo_types, :members do |t|
      t.index [:abo_type_id, :member_id]
    end
  end
end
