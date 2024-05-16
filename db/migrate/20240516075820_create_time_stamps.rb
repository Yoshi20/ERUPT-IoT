class CreateTimeStamps < ActiveRecord::Migration[6.1]
  def change
    create_table :time_stamps do |t|
      t.datetime :value
      t.boolean :is_in, default: false
      t.boolean :is_out, default: false
      t.bigint :sick_time # in s
      t.bigint :paid_leave_time # in s
      t.bigint :extra_time # in s
      t.bigint :delta_time # in s
      t.bigint :monthly_time # in s
      t.bigint :removed_break_time, default: 0 # in s
      t.bigint :added_night_time, default: 0 # in s
      t.boolean :was_automatically_clocked_out, default: false
      t.boolean :was_manually_edited, default: false
      t.boolean :was_manually_validated, default: false

      t.timestamps
    end
    add_column :time_stamps, :scan_event_id, :bigint
    add_foreign_key :time_stamps, :scan_events
    add_index :time_stamps, :scan_event_id
    add_column :time_stamps, :user_id, :bigint
    add_foreign_key :time_stamps, :users
    add_index :time_stamps, :user_id

    if table_exists?(:time_stamps)
      time_stamps = []
      ScanEvent.includes(:member).where.not(hourly_worker_time_stamp: nil).each do |se|
        member = se.member
        user = User.find_by(email: member.email)
        if user.nil?
          user = User.create!(
            email: member.email,
            username: member.first_name,
            password: "123456", # must be updated by the user afterwards
          )
        end
        time_stamps << {
          value: se.hourly_worker_time_stamp,
          is_in: se.hourly_worker_in,
          is_out: se.hourly_worker_out,
          delta_time: se.hourly_worker_delta_time,
          monthly_time: se.hourly_worker_monthly_time,
          removed_break_time: se.hourly_worker_has_removed_30_min ? 1800 : 0,
          was_automatically_clocked_out: se.hourly_worker_was_automatically_clocked_out,
          scan_event_id: se.id,
          user_id: user.id,
          created_at: se.created_at,
          updated_at: se.updated_at,
        }
      end
      TimeStamp.insert_all(time_stamps)
    end
  end
end
