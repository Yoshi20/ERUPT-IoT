class Member < ApplicationRecord
  has_and_belongs_to_many :abo_types
  has_many :scan_events, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :card_id, uniqueness: true

  def new?
    (!self.active || !self.card_id.present?) && self.created_at.today?
  end

end
