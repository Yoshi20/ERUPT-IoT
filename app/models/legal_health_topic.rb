class LegalHealthTopic < ApplicationRecord
  has_many :legal_health_params

  validates :name, presence: true
  validates :weighting, presence: true

  def self::max_value
    max_value = 0
    LegalHealthTopic.all.each do |lht|
      max_value += lht.legal_health_params.map{ |lhp| 10.to_f * lht.weighting }.sum
    end
    return max_value
  end

end
