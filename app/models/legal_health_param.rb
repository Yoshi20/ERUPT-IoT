class LegalHealthParam < ApplicationRecord
  belongs_to :legal_health_topic
  has_many :legal_health_evals

  validates :description, presence: true

end
