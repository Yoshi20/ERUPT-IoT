class TimeStamp < ApplicationRecord
  belongs_to :scan_event, optional: true
  belongs_to :user

  REMOVE_15MIN_AFTER = 5.5
  REMOVE_30MIN_AFTER = 7
  REMOVE_60MIN_AFTER = 9

  def type
    if self.sick_time.to_i > 0
      "SICK"
    elsif self.paid_leave_time.to_i > 0
      "HOLIDAY"
    elsif self.was_automatically_clocked_out
      "OUT (AUTO)"
    elsif self.is_out && self.was_manually_edited
      "OUT (MANUALLY)"
    elsif self.is_out
      "OUT"
    elsif self.is_in && self.was_manually_edited
      "IN (MANUALLY)"
    elsif self.is_in
      "IN"
    else
      "?"
    end
  end

  def new?
    self.created_at > 5.minute.ago
  end

  def clock_in
    last_time_stamps = TimeStamp.where(user_id: self.user_id).where.not(scan_event_id: self.scan_event_id).where("value <= ?", self.value)
    # find monthly_time
    last_time_stamp_out = last_time_stamps.where(is_out: true).order(:value).last # can be nil
    monthly_time = last_time_stamp_out&.monthly_time
    # set object params
    self.is_in = true
    self.is_out = false
    self.delta_time = nil
    self.monthly_time = monthly_time
    self.removed_break_time = 0
    self.added_night_time = 0
    # start the automatic clock out delayed job
    automatic_clock_out_in = 12.hours
    puts TimeStamp.delay(run_at: automatic_clock_out_in.from_now, queue: "time_stamp_#{self.id}").create(
      value: (self.value + automatic_clock_out_in),
      is_in: false,
      is_out: true,
      delta_time: automatic_clock_out_in.to_i,
      # removed_break_time: 0,
      # added_night_time: 0,
      was_automatically_clocked_out: true,
      scan_event_id: self.scan_event_id,
      user_id: self.user_id,
    )
  end

  def clock_out # Note: value, user_id & scan_event_id must be set beforehand
    last_time_stamps = TimeStamp.where(user_id: self.user_id).where.not(scan_event_id: self.scan_event_id).where("value <= ?", self.value)
    # calculate delta_time
    last_time_stamp_in = last_time_stamps.where(is_in: true).order(:value).last # can be nil
    delta_time = self.value.to_i - last_time_stamp_in&.value.to_i
    # handle removed_break_time & update delta_time
    removed_break_time = TimeStamp::break_time_to_remove(delta_time)
    delta_time = delta_time - removed_break_time
    # calculate monthly_time
    time_stamps_this_month = last_time_stamps.where(is_out: true).where("value >= ?", TimeStamp::beginning_of_work_month(self.value))
    monthly_time = delta_time + time_stamps_this_month.sum(&:delta_time)
    # set object params
    self.is_in = false
    self.is_out = true
    self.delta_time = delta_time
    self.monthly_time = monthly_time
    self.removed_break_time = removed_break_time
    self.added_night_time = 0 # TODO
    # delete the automatic clock out delayed job
    Delayed::Job.find_by(queue: "time_stamp_#{last_time_stamp_in.id}")&.destroy
    Delayed::Job.find_by(queue: "time_stamp_#{self.id}")&.destroy
  end

  # a work month starts at the 25. (06:00:00) and ends at the 25. (05:59:59)
  def self::beginning_of_work_month(ts)
    if (ts - 6.hours).day > 25
      ts.beginning_of_month + 24.days + 6.hours
    else
      ts.prev_month.beginning_of_month + 24.days + 6.hours
    end
  end

  def self::break_time_to_remove(delta_time)
    if delta_time > TimeStamp::REMOVE_60MIN_AFTER.hours.to_i
      60.minutes.to_i
    elsif delta_time > TimeStamp::REMOVE_30MIN_AFTER.hours.to_i
      30.minutes.to_i
    elsif delta_time > TimeStamp::REMOVE_15MIN_AFTER.hours.to_i
      15.minutes.to_i
    else
      0
    end
  end

end
