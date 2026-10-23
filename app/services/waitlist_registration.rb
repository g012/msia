class WaitlistRegistration
  def self.call(attributes:, product_ids:, category_ids:, visitor_key: nil)
    signup = WaitlistSignup.new(attributes)
    # Validate every submitted field before handling an existing email.
    if WaitlistSignup.exists?(email: signup.email)
      return [ nil, :duplicate ] if signup.consent == "1"
    end
    WaitlistSignup.transaction do
      signup.save!
      signup.categories = Category.where(id: category_ids)
      Product.visible.where(id: product_ids).find_each do |product|
        signup.product_interests.create!(product: product, visitor_key: "signup:#{signup.id}")
      end
      ProductInterest.where(visitor_key: visitor_key).delete_all if visitor_key.present?
      # GoodJob inserts the email into the same PostgreSQL transaction.
      WaitlistMailer.welcome(signup).deliver_later
    end
    [ signup, :created ]
  rescue ActiveRecord::RecordNotUnique
    [ nil, :duplicate ]
  rescue ActiveRecord::RecordInvalid
    [ signup, :invalid ]
  end
end
