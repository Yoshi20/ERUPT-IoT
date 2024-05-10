class ScanEvent < ApplicationRecord
  belongs_to :member, optional: true

  delegate :first_name, :last_name, to: :member, prefix: true

  scope :no_member, -> { where(member_id: nil) }

  REMOVE_30MIN_AFTER = 8

  def has_member?
    self.member_id.present?
  end

  def new?
    self.created_at > 5.minute.ago
  end

end
