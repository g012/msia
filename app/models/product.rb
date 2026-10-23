class Product < ApplicationRecord
  belongs_to :brand
  belongs_to :supplier, optional: true
  has_many :product_translations, dependent: :destroy
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  has_many :product_sources, dependent: :destroy
  has_many :product_interests, dependent: :destroy
  has_one_attached :photo
  accepts_nested_attributes_for :product_translations, allow_destroy: true
  accepts_nested_attributes_for :product_sources, allow_destroy: true, reject_if: ->(attrs) { attrs.values_at("source_name", "url", "image_url", "confirmed_facts", "unknown_facts").all?(&:blank?) }

  enum :halal_status, %w[unknown claimed certified].index_with(&:itself), prefix: :halal
  enum :eu_compliance_status, %w[unknown investigating documentation_received approved_for_import].index_with(&:itself), prefix: :eu
  enum :launch_status, %w[researching candidate planned coming_soon available rejected].index_with(&:itself), prefix: :launch

  scope :visible, -> { where.not(launch_status: "rejected") }
  scope :with_catalogue, -> { includes(:brand, :categories, :product_translations, photo_attachment: :blob) }
  validates :name, :slug, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }
  validates :illustration, inclusion: { in: %w[noodles coffee tea snacks pantry] }
  validate :safe_photo
  validates :official_source_url, format: { with: /\Ahttps:\/\/[^\s]+\z/ }, allow_blank: true

  def to_param
    slug
  end

  def translation(locale = I18n.locale)
    product_translations.find { |tr| tr.locale == locale.to_s }
  end

  def display_name
    translation&.name.presence || name
  end

  private

  def safe_photo
    return unless photo.attached?
    errors.add(:photo, "must be JPEG, PNG or WebP under 8 MB") unless photo.content_type.in?(%w[image/jpeg image/png image/webp]) && photo.byte_size <= 8.megabytes
  end
end
