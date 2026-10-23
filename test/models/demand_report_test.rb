require "test_helper"

class DemandReportTest < ActiveSupport::TestCase
  test "category demand deduplicates direct selection and multiple favourites and excludes unsubscribed people" do
    category = Category.create!(slug: "noodles", name_fr: "Nouilles", name_en: "Noodles")
    one = catalogue_product
    two = catalogue_product(slug: "another-noodle")
    [ one, two ].each { |product| product.categories << category }
    confirmed = subscriber(confirmed_at: Time.current)
    confirmed.categories << category
    [ one, two ].each { |product| confirmed.product_interests.create!(product: product, visitor_key: "signup:#{confirmed.id}") }
    pending = subscriber(email: "pending@example.com")
    pending.categories << category
    unsubscribed = subscriber(email: "gone@example.com", confirmed_at: Time.current, unsubscribed_at: Time.current)
    unsubscribed.categories << category
    assert_equal 2, DemandReport.category_counts[category.id]
    assert_equal 1, DemandReport.category_counts(confirmed: true)[category.id]
  end
end
