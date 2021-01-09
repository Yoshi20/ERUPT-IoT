class Device < ApplicationRecord
  belongs_to :user
  belongs_to :device_type
  # has_many :events

  validates :name, :dev_eui, presence: true

end
