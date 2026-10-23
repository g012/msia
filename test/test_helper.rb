ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  parallelize(workers: 1)
  include ActiveJob::TestHelper

  def catalogue_product(slug: "pan-mee", status: "candidate", vegetarian: nil)
    brand = Brand.find_or_create_by!(slug: "hock-kee") { |b| b.name = "Hock Kee" }
    product = Product.create!(name: "Official Pan Mee", slug: slug, brand: brand, launch_status: status, vegetarian: vegetarian)
    %w[fr en].each { |locale| product.product_translations.create!(locale: locale, name: "Pan Mee #{locale}", short_description: "A verified catalogue reference.") }
    product
  end

  def subscriber(email: "reader@example.com", **attributes)
    WaitlistSignup.create!({ email: email, country: "FR", locale: "fr", consent: "1", consented_at: Time.current }.merge(attributes))
  end
end
