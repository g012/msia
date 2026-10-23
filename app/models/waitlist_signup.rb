class WaitlistSignup < ApplicationRecord
  COUNTRIES = %w[FR BE DE NL ES IT LU AT IE PT DK SE FI PL CZ GR RO HU BG HR SI SK EE LV LT CY MT OTHER].freeze
  CONNECTIONS = %w[lived visited curious].freeze
  attr_accessor :consent
  normalizes :email, with: ->(email) { email.strip.downcase }
  has_many :product_interests, dependent: :destroy
  has_many :products, through: :product_interests
  has_many :waitlist_category_interests, dependent: :destroy
  has_many :categories, through: :waitlist_category_interests
  validates :email, presence: true, uniqueness: true, length: { maximum: 254 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :country, inclusion: { in: COUNTRIES }
  validates :locale, inclusion: { in: %w[fr en] }
  validates :consent, acceptance: { allow_nil: false }, on: :create
  validates :consented_at, presence: true
  validates :first_name, :postcode, length: { maximum: 100 }
  validates :import_wish, length: { maximum: 2000 }
  validates :connection_to_malaysia, inclusion: { in: CONNECTIONS }, allow_blank: true
  validates :utm_source, :utm_medium, :utm_campaign, :utm_content, length: { maximum: 200 }
  scope :active, -> { where(unsubscribed_at: nil) }
  scope :confirmed, -> { active.where.not(confirmed_at: nil) }

  def management_token
    signed_id(purpose: :preferences, expires_in: 90.days)
  end

  def unsubscribe_token
    signed_id(purpose: :unsubscribe)
  end

  def confirmation_token
    signed_id(purpose: :confirmation, expires_in: 7.days)
  end
end
