class Order < ApplicationRecord
  belongs_to :device

  scope :open, -> { where(acknowledged: false) }
  scope :closed, -> { where(acknowledged: true).order(acknowledged_at: :desc) }

  def new?
    self.acknowledged_at > 5.minute.ago
  end

  def acknowledge(user)
    self.acknowledged = true
    self.acknowledged_at = Time.now
    self.acknowledged_by = user.username
  end

end
