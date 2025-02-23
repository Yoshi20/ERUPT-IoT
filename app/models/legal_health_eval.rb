class LegalHealthEval < ApplicationRecord
  belongs_to :legal_health_param
  belongs_to :legal_health_customer

  validates :value, presence: true

  def weighted_value
    self.value.to_f * self.legal_health_param.legal_health_topic.weighting
  end

  def weighted_max_value
    10.to_f * self.legal_health_param.legal_health_topic.weighting
  end

end
