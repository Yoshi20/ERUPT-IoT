class LegalHealthCustomer < ApplicationRecord
  has_many :legal_health_evals

  validates :name, presence: true

end
