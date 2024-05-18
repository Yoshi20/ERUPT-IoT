class AddIsSickToTimeStamps < ActiveRecord::Migration[6.1]
  def change
    add_column :time_stamps, :is_sick, :boolean, default: false
    add_column :time_stamps, :is_paid_leave, :boolean, default: false
    TimeStamp.all.each do |ts|
      if ts.respond_to?(:is_sick)
        ts.update(
          is_sick: ts.sick_time.to_i > 0,
          is_paid_leave: ts.paid_leave_time.to_i > 0,
        )
      end
    end
    remove_column :time_stamps, :sick_time
    remove_column :time_stamps, :paid_leave_time
  end
end
