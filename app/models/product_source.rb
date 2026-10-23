class ProductSource < ApplicationRecord
  belongs_to :product
  validates :source_name, :url, presence: true
  validates :url, format: { with: /\Ahttps:\/\/[^\s]+\z/ }
  validates :image_rights_status, inclusion: { in: %w[permission_required permitted original] }
end
