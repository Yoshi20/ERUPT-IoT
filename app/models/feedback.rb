class Feedback < ApplicationRecord

  def new?
    !self.read && self.created_at.today?
  end

end
