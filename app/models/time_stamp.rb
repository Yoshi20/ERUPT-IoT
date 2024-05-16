class TimeStamp < ApplicationRecord
  belongs_to :scan_event, optional: true
  belongs_to :user

  REMOVE_15MIN_AFTER = 5.5
  REMOVE_30MIN_AFTER = 7
  REMOVE_60MIN_AFTER = 9

  def new?
    self.created_at > 5.minute.ago
  end

end
