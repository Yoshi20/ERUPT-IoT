class ScanEvent < ApplicationRecord
  belongs_to :member, optional: true

end
