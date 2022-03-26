class Order < ApplicationRecord
  belongs_to :device

  def new?
    self.created_at > 5.minute.ago
  end

end
