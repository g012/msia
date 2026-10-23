class Category < ApplicationRecord
  has_many :product_categories, dependent: :destroy
  has_many :products, through: :product_categories
  has_many :waitlist_category_interests, dependent: :destroy
  validates :slug, :name_fr, :name_en, presence: true
  validates :slug, uniqueness: true

  def name
    public_send("name_#{I18n.locale}")
  end
end
