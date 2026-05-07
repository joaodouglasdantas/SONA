class Emotion < ApplicationRecord
  belongs_to :user

  before_validation :set_recorded_at, on: :create

  validates :mood, presence: true
  validates :intensity, presence: true, numericality: { in: 1..10 }
  validates :recorded_at, presence: true

  private

  def set_recorded_at
    self.recorded_at = Time.current
  end
end
