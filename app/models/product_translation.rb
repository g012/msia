class ProductTranslation < ApplicationRecord
  belongs_to :product
  validates :locale, :name, presence: true
  validates :locale, inclusion: { in: %w[fr en de nl es it] }, uniqueness: { scope: :product_id }
  before_save :invalidate_review

  private

  def invalidate_review
    fields = %w[ingredients allergens nutrition preparation]
    if fields.any? { |field| will_save_change_to_attribute?(field) }
      self.regulated_reviewed = false
      self.regulated_reviewed_at = nil
    elsif will_save_change_to_regulated_reviewed? && regulated_reviewed?
      self.regulated_reviewed_at = Time.current
    end
  end
end
