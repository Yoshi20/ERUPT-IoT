class Feedback < ApplicationRecord
  validates :location_rating, :event_rating, presence: true

  def new?
    !self.read && self.created_at.today?
  end

end
