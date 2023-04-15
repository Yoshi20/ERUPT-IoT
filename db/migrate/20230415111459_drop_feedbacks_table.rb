class DropFeedbacksTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :feedbacks
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
