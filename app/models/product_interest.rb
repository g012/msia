class ProductInterest < ApplicationRecord
  belongs_to :product
  belongs_to :waitlist_signup, optional: true
  validates :visitor_key, presence: true, uniqueness: { scope: :product_id }
end
