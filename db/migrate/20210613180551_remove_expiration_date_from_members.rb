class RemoveExpirationDateFromMembers < ActiveRecord::Migration[6.1]
  def change
    remove_column :members, :expiration_date, :datetime
  end
end
