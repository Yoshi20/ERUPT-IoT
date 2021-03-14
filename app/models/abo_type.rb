class AboType < ApplicationRecord
  has_and_belongs_to_many :members

  validates :name, presence: true, uniqueness: true

end
