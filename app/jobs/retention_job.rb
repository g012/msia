class RetentionJob < ApplicationJob
  def perform
    WaitlistSignup.where(confirmed_at: nil).where("created_at < ?", 30.days.ago).find_each(&:destroy!)
    WaitlistSignup.where("unsubscribed_at < ?", 30.days.ago).find_each(&:destroy!)
    WaitlistSignup.where("consented_at < ?", 24.months.ago).find_each(&:destroy!)
    ProductInterest.where(waitlist_signup_id: nil).where("created_at < ?", 90.days.ago).delete_all
  end
end
