class RemoveActiveFromMembers < ActiveRecord::Migration[6.1]
  def change
    remove_column :members, :active, :boolean
  end
end
