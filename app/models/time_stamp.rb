class TimeStamp < ApplicationRecord
  belongs_to :scan_event, optional: true
  belongs_to :user

  REMOVE_15MIN_AFTER = 5.5
  REMOVE_30MIN_AFTER = 7
  REMOVE_60MIN_AFTER = 9

  def type
    if self.has_sick_time?
      "SICK"
    elsif self.has_paid_leave_time?
      "HOLIDAY"
    elsif self.was_automatically_clocked_out
      "OUT (AUTO)"
    elsif self.is_out
      "OUT"
    elsif self.is_in
      "IN"
    else
      "?"
    end
  end

  def type_color
    if self.has_sick_time?
      "burlywood"
    elsif self.has_paid_leave_time?
      "deepskyblue"
    elsif self.was_automatically_clocked_out
      "red"
    elsif self.is_out
      "lightgreen"
    elsif self.is_in
      "yellow"
    else
      "red"
    end
  end

  def new?
    self.created_at > 5.minute.ago
  end

  def has_sick_time?
    self.sick_time.to_i > 0
  end

  def has_paid_leave_time?
    self.paid_leave_time.to_i > 0
  end

  def clock_in
    last_time_stamps = TimeStamp.where(user_id: self.user_id).where.not(id: self.id).where("value <= ?", self.value)
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
  end

  def start_auto_clock_out
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

  def clock_out # Note: user_id & value must be set beforehand
    last_time_stamps = TimeStamp.where(user_id: self.user_id).where.not(id: self.id).where("value <= ?", self.value)
    # calculate delta_time
    last_time_stamp_in = last_time_stamps.where(is_in: true).order(:value).last # can be nil?
    last_value_in = last_time_stamp_in&.value
    delta_time = self.value.to_i - last_value_in.to_i
    # handle removed_break_time & update delta_time
    removed_break_time = TimeStamp::break_time_to_remove(delta_time)
    delta_time = delta_time - removed_break_time
    # handle added_night_time & update delta_time
    added_night_time = TimeStamp::night_time_to_add(last_value_in, self.value)
    delta_time = delta_time + added_night_time
    # calculate monthly_time
    time_stamps_this_month = last_time_stamps.where(is_out: true).where("value >= ?", TimeStamp::beginning_of_work_month(self.value))
    monthly_time = delta_time + time_stamps_this_month&.sum(&:delta_time).to_i
    # set object params
    self.is_in = false
    self.is_out = true
    self.delta_time = delta_time
    self.monthly_time = monthly_time
    self.removed_break_time = removed_break_time
    self.added_night_time = added_night_time
    # delete the automatic clock out delayed job
    Delayed::Job.find_by(queue: "time_stamp_#{last_time_stamp_in.id}")&.destroy if last_time_stamp_in.present?
    Delayed::Job.find_by(queue: "time_stamp_#{self.id}")&.destroy
  end

  def clock_absence(params)
    # calculate monthly_time
    last_time_stamps = TimeStamp.where(user_id: self.user_id).where.not(id: self.id).where("value <= ?", self.value)
    time_stamps_this_month = last_time_stamps.where(is_out: true).where("value >= ?", TimeStamp::beginning_of_work_month(self.value))
    monthly_time = delta_time + time_stamps_this_month&.sum(&:delta_time).to_i
    if params["absence_dur"].present? || params["absence_type"].present?
      # get absence_time
      absence_time = TimeStamp::absence_time_for(params["absence_dur"])
      # set object params
      self.is_in = false
      self.is_out = false
      self.sick_time = params["absence_type"] == "sick" ? absence_time : self.sick_time
      self.paid_leave_time = params["absence_type"] == "paid_leave" ? absence_time : self.paid_leave_time
      self.delta_time = absence_time
      self.monthly_time = monthly_time
      self.removed_break_time = 0
      self.added_night_time = 0
    else
      # just update monthly_time
      self.monthly_time = monthly_time
    end
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

  # add 10% to the time when between 00:00 and 07:00
  def self::night_time_to_add(value_in, value_out)
    time_to_add = 0
    start_of_night_time = value_out.beginning_of_day  # 00:00
    end_of_night_time = start_of_night_time + 7.hours # 07:00
    # first check if value_out is within the relevant night time
    if value_out > start_of_night_time && value_out <= end_of_night_time
      # set start_time depending on whether clock_in was before or after start_of_night_time
      start_time = value_in < start_of_night_time ? start_of_night_time : value_in
      relevant_delta = value_out.to_i - start_time.to_i
      time_to_add = relevant_delta * 10 / 100 # 10%
    # also check if value_in is within the relevant night time (even through value_out aint)
    elsif value_in > start_of_night_time && value_in <= end_of_night_time
      relevant_delta = end_of_night_time.to_i - value_in.to_i
      time_to_add = relevant_delta * 10 / 100 # 10%
    end
    return time_to_add
  end

  def self.absence_time_for(absence_dur)
    case absence_dur
      when "half_day" then 4.hours.to_i
      when "day" then 8.hours.to_i
      when "week" then 7.days.to_i
      else 0
    end
  end
end
