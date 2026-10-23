class WaitlistCategoryInterest < ApplicationRecord
  belongs_to :waitlist_signup
  belongs_to :category
end
