class AddLockedToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :locked, :boolean, default: false
    change_column_null :members, :first_name, true
    change_column_null :members, :last_name, true
  end
end
