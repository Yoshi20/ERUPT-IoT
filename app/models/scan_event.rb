class ScanEvent < ApplicationRecord
  belongs_to :member, optional: true

  def has_member?
    self.member_id.present?
  end

  def new?
    self.created_at > 5.minute.ago
  end

end
