class AddFullNameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :full_name, :string
    add_column :users, :mobile_number, :string

  end
end
