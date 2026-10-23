require "test_helper"

class WaitlistTest < ActionDispatch::IntegrationTest
  setup { ActiveJob::Base.queue_adapter = :test }

  test "signup normalizes email, records consent, selected products and queues a welcome email" do
    product = catalogue_product
    category = Category.create!(slug: "pan-mee", name_fr: "Pan Mee", name_en: "Pan Mee")
    assert_difference "WaitlistSignup.count", 1 do
      assert_enqueued_emails 1 do
        post waitlist_signups_path(locale: :fr), params: { waitlist_signup: { email: "  Reader@Example.COM ", country: "FR", consent: "1" }, product_ids: [ product.id ], category_ids: [ category.id ] }
      end
    end
    assert_redirected_to thank_you_path(locale: :fr)
    signup = WaitlistSignup.last
    assert_equal "reader@example.com", signup.email
    assert signup.consented_at
    assert_nil signup.confirmed_at
    assert_equal "launch-v1", signup.consent_version
    assert_equal [ product.id ], signup.product_ids
    assert_equal [ category.id ], signup.category_ids
    follow_redirect!
    assert_response :success
    assert_select "h1", I18n.t("waitlist.thank_title", locale: :fr)
  end

  test "missing or unchecked consent is rejected" do
    [ nil, "0" ].each do |consent|
      assert_no_difference "WaitlistSignup.count" do
        post waitlist_signups_path(locale: :en), params: { waitlist_signup: { email: "consent@example.com", country: "FR", consent: consent } }
      end
      assert_response :unprocessable_entity
    end
  end

  test "email and country must be valid" do
    post waitlist_signups_path(locale: :en), params: { waitlist_signup: { email: "invalid", country: "ZZ", consent: "1" } }
    assert_response :unprocessable_entity
    assert_equal 0, WaitlistSignup.count
  end

  test "duplicate email does not modify preferences, reactivate consent or resend email" do
    signup = subscriber(unsubscribed_at: 1.day.ago)
    original_consent = signup.consented_at
    assert_no_difference [ "WaitlistSignup.count", "ProductInterest.count" ] do
      assert_no_enqueued_emails do
        post waitlist_signups_path(locale: :en), params: { waitlist_signup: { email: "READER@EXAMPLE.COM", country: "BE", consent: "1" } }
      end
    end
    assert_response :redirect
    assert_equal "FR", signup.reload.country
    assert_equal original_consent, signup.consented_at
    assert signup.unsubscribed_at?
    follow_redirect!
    assert_select "form.preferences-form", count: 0
  end

  test "UTM attribution follows signed context and ignores injected fields" do
    get localized_root_path(locale: :fr), params: { utm_source: "instagram", utm_medium: "paid", utm_campaign: "first-noodles", utm_content: "creative-a" }
    assert_response :success
    ref = Nokogiri::HTML(response.body).at_css("a.header-join")["href"]
    token = Rack::Utils.parse_query(URI.parse(ref).query)["ref"]
    post waitlist_signups_path(locale: :fr), params: { ref: token, waitlist_signup: { email: "utm@example.com", country: "FR", consent: "1", utm_source: "forged", confirmed_at: Time.current } }
    signup = WaitlistSignup.last
    assert_equal "instagram", signup.utm_source
    assert_equal "paid", signup.utm_medium
    assert_equal "first-noodles", signup.utm_campaign
    assert_equal "creative-a", signup.utm_content
    assert_equal "/fr", signup.landing_page
    assert_nil signup.confirmed_at
  end

  test "untrusted attribution token cannot set arbitrary landing or campaign" do
    post waitlist_signups_path(locale: :en), params: { ref: "tampered", landing_page: "https://evil.example", waitlist_signup: { email: "safe@example.com", country: "FR", consent: "1" } }
    assert_nil WaitlistSignup.last.utm_source
    assert_equal "/en/waitlist", WaitlistSignup.last.landing_page
  end

  test "unsubscribing needs a valid token and explicit POST; GET is safe" do
    signup = subscriber(confirmed_at: Time.current)
    product = catalogue_product
    signup.product_interests.create!(product: product, visitor_key: "signup:#{signup.id}")
    get unsubscribe_path(locale: :en, token: signup.unsubscribe_token)
    assert_response :success
    assert_nil signup.reload.unsubscribed_at
    assert_equal "no-store", response.headers["Cache-Control"]
    post unsubscribe_path(locale: :en, token: signup.unsubscribe_token)
    assert_response :success
    assert signup.reload.unsubscribed_at?
    assert_empty signup.product_interests
    post preferences_path(locale: :en, token: signup.management_token), params: {}
    assert_response :not_found
    get unsubscribe_path(locale: :en, token: "wrong")
    assert_response :not_found
  end

  test "confirmation is explicit and cannot reactivate an unsubscribed user" do
    signup = subscriber
    get confirmation_path(locale: :en, token: signup.confirmation_token)
    assert_nil signup.reload.confirmed_at
    post confirmation_path(locale: :en, token: signup.confirmation_token)
    assert signup.reload.confirmed_at?
    signup.update!(unsubscribed_at: Time.current)
    post confirmation_path(locale: :en, token: signup.confirmation_token)
    assert signup.reload.unsubscribed_at?
  end

  test "optional preferences update only through a valid management link" do
    signup = subscriber
    product = catalogue_product
    patch preferences_path(locale: :fr, token: signup.management_token), params: { waitlist_signup: { first_name: "Camille", postcode: "75011", import_wish: "Kaya", connection_to_malaysia: "visited", email: "forged@example.com" }, product_ids: [ product.id ] }
    assert_response :redirect
    assert_equal "Kaya", signup.reload.import_wish
    assert_equal "reader@example.com", signup.email
    assert_equal [ product.id ], signup.product_ids
    assert_no_difference "WaitlistSignup.count" do
      patch preferences_path(locale: :fr, token: "wrong"), params: { waitlist_signup: { first_name: "Evil" } }
    end
    assert_response :not_found
  end
end
