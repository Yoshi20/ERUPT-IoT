class AddMemberIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :member_id, :bigint
    add_foreign_key :users, :members
    add_index :users, :member_id
  end
end
