require "test_helper"

class CatalogueTest < ActionDispatch::IntegrationTest
  test "root safely infers language and defaults to French" do
    get "/", headers: { "Accept-Language" => "fr-FR,fr;q=0.9,en;q=0.8" }
    assert_redirected_to "/fr"
    get "/", headers: { "Accept-Language" => "en-GB,en;q=0.9" }
    assert_redirected_to "/en"
    get "/", headers: { "Accept-Language" => "ja" }
    assert_redirected_to "/fr"
    get "/de"
    assert_response :not_found
  end

  test "French and English pages, source sections, legal pages and sitemap render" do
    product = catalogue_product
    %w[fr en].each do |locale|
      get localized_root_path(locale: locale)
      assert_response :success
      assert_select "html[lang='#{locale}']"
      assert_select "h1", count: 1
      assert_select "a[href*='/#{locale}/waitlist/new']"
      get product_path(locale: locale, id: product.slug)
      assert_response :success
      assert_select "script[type='application/ld+json']", count: 0
      %w[about faq privacy legal epicerie-malaisienne nouilles-malaisiennes pan-mee kolo-mee kopitiam].each do |page|
        get "/#{locale}/#{page}"
        assert_response :success, "#{locale}/#{page}"
        assert_select "h1", count: 1
      end
    end
    get "/sitemap.xml"
    assert_response :success
    assert_includes response.body, "/fr/products/pan-mee"
    get "/robots.txt"
    assert_response :success
    assert_includes response.body, "Disallow: /fr/admin"
  end

  test "rejected products cannot be browsed, voted for, or selected through signup" do
    product = catalogue_product(status: "rejected")
    get products_path(locale: :en)
    assert_response :success
    assert_select "h3", text: /Pan Mee/, count: 0
    get product_path(locale: :en, id: product.slug)
    assert_response :not_found
    post product_interests_path(locale: :en, product_id: product.slug)
    assert_response :not_found
    post waitlist_signups_path(locale: :en), params: { waitlist_signup: { email: "no-rejected@example.com", country: "FR", consent: "1" }, product_ids: [ product.id ] }
    assert_empty WaitlistSignup.last.products
  end

  test "unknown dietary states do not match confirmed filters" do
    unknown = catalogue_product
    vegetarian = catalogue_product(slug: "vegetarian-pan-mee", vegetarian: true)
    get products_path(locale: :en), params: { diet: "vegetarian" }
    assert_response :success
    assert_select "h3 a[href*='vegetarian-pan-mee']", count: 1
    assert_select "h3 a[href*='/products/pan-mee?']", count: 0
    get products_path(locale: :en), params: { spicy: "no" }
    assert_select "article.product-card", count: 0
    assert_nil unknown.reload.spicy
    assert_nil vegetarian.contains_animal_products
  end

  test "intent is stored and deduplicated, then consolidated on signup" do
    product = catalogue_product
    assert_difference "ProductInterest.count", 1 do
      2.times { post product_interests_path(locale: :en, product_id: product.slug) }
    end
    post waitlist_signups_path(locale: :en), params: { waitlist_signup: { email: "interest@example.com", country: "FR", consent: "1" }, product_ids: [ product.id ] }
    assert_equal 1, ProductInterest.count
    assert_equal WaitlistSignup.last.id, ProductInterest.last.waitlist_signup_id
  end

  test "canonical has no campaign or signed context; page views are aggregate rows" do
    2.times { get localized_root_path(locale: :en), params: { utm_source: "test" } }
    assert_select "link[rel=canonical][href='http://localhost:3000/en']", count: 1
    assert_equal 1, PageMetric.count
    assert_equal 2, PageMetric.first.views
    assert_equal %w[id day path views].sort, PageMetric.column_names.sort
  end

  test "regulated translations remain explicitly unverified until reviewed" do
    product = catalogue_product
    tr = product.translation(:fr)
    tr.update!(ingredients: "Information traduite", regulated_reviewed: true)
    assert_not tr.regulated_reviewed?
    get product_path(locale: :fr, id: product.slug)
    assert_select ".review-notice", count: 1
    tr.update!(regulated_reviewed: true)
    assert tr.regulated_reviewed_at
    get product_path(locale: :fr, id: product.slug)
    assert_select ".review-notice", count: 0
    tr.update!(ingredients: "Nouvelle information")
    assert_not tr.regulated_reviewed?
  end
  test "first visit has a nonempty CSP nonce matching importmap scripts" do
    get localized_root_path(locale: :en)
    nonce = Nokogiri::HTML(response.body).at_css("script[type='importmap']")["nonce"]
    assert nonce.present?
    assert_includes response.headers["Content-Security-Policy"], "'nonce-#{nonce}'"
    assert_not_includes response.headers["Content-Security-Policy"], "'nonce-'"
  end
end
