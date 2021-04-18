class ChangeCardIdConstrait < ActiveRecord::Migration[6.1]
  def up
    change_column :members, :card_id, :string, null: true, unique: true
  end
  def down
    change_column :members, :card_id, :string, null: false, unique: true
  end
end
