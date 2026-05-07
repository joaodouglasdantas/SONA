class Emotion < ApplicationRecord
  belongs_to :user

  validates :mood, presence: true
  validates :intensity, presence: true, numericality: { in: 1..10 }
  validates :recorded_at, presence: true
end
