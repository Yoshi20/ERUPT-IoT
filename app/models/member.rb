class Member < ApplicationRecord
  has_many :abo_types_members
  has_many :abo_types, through: :abo_types_members
  has_many :scan_events, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :card_id, uniqueness: true, allow_blank: true

  def new?
    (!self.active || !self.card_id.present?) && self.created_at.today?
  end

end
