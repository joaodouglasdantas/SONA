class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :emotions, dependent: :destroy

  # Fotos do avatar Sims
  has_one_attached :original_photo
  has_one_attached :sims_avatar

  validates :first_name, presence: true
  validates :last_name, presence: true

  def display_name
    sim_name.presence || first_name
  end

  def sim_display_name
    sim_name.presence || "#{first_name} #{last_name}"
  end
end
