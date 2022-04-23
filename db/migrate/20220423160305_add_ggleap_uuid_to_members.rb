class AddGgleapUuidToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :ggleap_uuid, :string
  end
end
