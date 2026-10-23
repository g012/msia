require "test_helper"

class RetentionJobTest < ActiveJob::TestCase
  test "retention erases expired personal data and anonymous signals, keeps recent subscribers" do
    stale = subscriber(email: "stale@example.com", created_at: 31.days.ago)
    recent = subscriber(email: "recent@example.com", confirmed_at: Time.current)
    unsubscribed = subscriber(email: "unsubscribed@example.com", confirmed_at: 2.months.ago, unsubscribed_at: 31.days.ago)
    product = catalogue_product
    ProductInterest.create!(product: product, visitor_key: "expired", created_at: 91.days.ago)
    RetentionJob.perform_now
    assert_not WaitlistSignup.exists?(stale.id)
    assert_not WaitlistSignup.exists?(unsubscribed.id)
    assert WaitlistSignup.exists?(recent.id)
    assert_empty ProductInterest.all
  end
end
