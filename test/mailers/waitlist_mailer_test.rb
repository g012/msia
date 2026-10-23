require "test_helper"

class WaitlistMailerTest < ActionMailer::TestCase
  test "welcome includes favourites, explicit confirmation, preferences and unsubscribe in signup language" do
    signup = subscriber(locale: "en")
    product = catalogue_product
    signup.product_interests.create!(product: product, visitor_key: "signup:#{signup.id}")
    mail = WaitlistMailer.welcome(signup)
    assert_equal [ signup.email ], mail.to
    assert_includes mail.subject, "confirm"
    assert_includes mail.text_part.body.to_s, "Pan Mee en"
    assert_includes mail.text_part.body.to_s, "/en/confirm?token="
    assert_includes mail.text_part.body.to_s, "/en/unsubscribe?token="
    assert_includes mail.text_part.body.to_s, "/en/preferences?token="
    assert_includes mail.header["List-Unsubscribe"].value, "/en/unsubscribe?token="
  end
end
