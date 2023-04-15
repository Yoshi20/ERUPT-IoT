class Feedback < ApplicationRecord

  validates :overall_rating, presence: true

  def new?
    !self.read && self.created_at.today?
  end

end
