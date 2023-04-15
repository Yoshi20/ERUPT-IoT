class RecreateFeedbacks < ActiveRecord::Migration[6.1]
  def change
    create_table :feedbacks do |t|
      t.integer :overall_rating, null: false
      t.integer :service_rating
      t.integer :ambient_rating
      t.string :how_often_do_you_visit
      t.string :what_to_improve
      t.string :what_to_keep
      t.integer :console_rating
      t.string :console_comment
      t.integer :pc_rating
      t.string :pc_comment
      t.integer :karaoke_rating
      t.string :karaoke_comment
      t.integer :board_game_rating
      t.string :board_game_comment
      t.integer :offer_rating
      t.string :offer_comment
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
