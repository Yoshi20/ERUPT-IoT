class AboType < ApplicationRecord
  has_many :abo_types_members
  has_many :members, through: :abo_types_members

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where('abo_types_members.expiration_date >= ?', Time.now) }

end
