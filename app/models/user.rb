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

  def handle_new_time_stamp!(scan_event_id)
    now = Time.now
    last_time_stamp = self.time_stamps.order(:value).last if self.time_stamps.any?
    if last_time_stamp.present? && last_time_stamp.is_in
      # clock out --------------------------------------------------------------
      time_stamp = TimeStamp.new(value: now, scan_event_id: scan_event_id, user_id: self.id)
      time_stamp.clock_out
      time_stamp.save!
    else
      # clock in ---------------------------------------------------------------
      time_stamp = TimeStamp.new(value: now, scan_event_id: scan_event_id, user_id: self.id)
      time_stamp.clock_in
      time_stamp.save!
      time_stamp.start_auto_clock_out
    end
  end

end
