class RenameDesciptionToDescription < ActiveRecord::Migration[6.1]
  def change
    rename_column :legal_health_params, :desciption, :description
  end
end
