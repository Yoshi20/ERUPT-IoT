class WifiDisplay < ApplicationRecord
  validates :dns, :path, presence: true

end
