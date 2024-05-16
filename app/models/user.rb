class User < ApplicationRecord
  belongs_to :member, optional: true
  has_many :devices
  has_many :time_stamps

  before_validation :strip_whitespace

  validates :username,
    :presence => true,
    :uniqueness => {
      :case_sensitive => false
    }
  validate :validate_username

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def strip_whitespace
    self.username.try(:strip!)
    self.email.try(:strip!)
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions.to_hash).first
    end
  end

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end

  def admin?
    self.is_admin == true
  end

  def handle_time_stamp(scan_event_id)
    now = Time.now
    last_time_stamps = TimeStamp.where(user_id: self.id).where.not(scan_event_id: scan_event_id).where("value <= ?", now)
    last_time_stamp = last_time_stamps.last
    if last_time_stamp.present? && last_time_stamp.is_in
      # clock out --------------------------------------------------------------
      delta_time = now.to_i - last_time_stamp&.value.to_i
      # handle removed_break_time & calculate delta_time
      removed_break_time = 0
      if delta_time > TimeStamp::REMOVE_15MIN_AFTER.hours.to_i
        removed_break_time = 15.minutes.to_i
      elsif delta_time > TimeStamp::REMOVE_30MIN_AFTER.hours.to_i
        removed_break_time = 30.minutes.to_i
      elsif delta_time > TimeStamp::REMOVE_60MIN_AFTER.hours.to_i
        removed_break_time = 60.minutes.to_i
      end
      delta_time = delta_time - removed_break_time
      # calculate monthly_time
      time_stamps_this_month = last_time_stamps.where(is_out: true).where("value >= ?", beginning_of_work_month(now))
      monthly_time = delta_time + time_stamps_this_month.sum(&:delta_time)
      # create time_stamp
      time_stamp = TimeStamp.create!(
        value: now,
        is_in: false,
        is_out: true,
        delta_time: delta_time,
        monthly_time: monthly_time,
        removed_break_time: removed_break_time,
        # added_night_time: 0, # TODO
        scan_event_id: scan_event_id,
        user_id: self.id,
      )
      # delete the automatic clock out delayed job
      Delayed::Job.find_by(queue: "time_stamp_#{last_time_stamp.id}")&.destroy
    else
      # clock in ---------------------------------------------------------------
      time_stamp = TimeStamp.create!(
        value: now,
        is_in: true,
        is_out: false,
        monthly_time: last_time_stamp&.monthly_time,
        scan_event_id: scan_event_id,
        user_id: self.id,
      )
      # start the automatic clock out delayed job
      automatic_clock_out_in = 12.hours
      puts TimeStamp.delay(run_at: automatic_clock_out_in.from_now, queue: "time_stamp_#{time_stamp.id}").create(
        value: (now + automatic_clock_out_in),
        is_in: false,
        is_out: true,
        delta_time: automatic_clock_out_in.to_i,
        # removed_break_time: 0,
        # added_night_time: 0,
        was_automatically_clocked_out: true,
        scan_event_id: scan_event_id,
        user_id: self.id,
      )
    end
  end

end
