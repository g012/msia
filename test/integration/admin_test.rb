require "test_helper"

class AdminTest < ActionDispatch::IntegrationTest
  setup do
    @old_user = ENV["ADMIN_USERNAME"]
    @old_password = ENV["ADMIN_PASSWORD"]
    ENV["ADMIN_USERNAME"] = "researcher"
    ENV["ADMIN_PASSWORD"] = "test-password-only"
  end
  teardown do
    ENV["ADMIN_USERNAME"] = @old_user
    ENV["ADMIN_PASSWORD"] = @old_password
  end

  def credentials
    { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("researcher", "test-password-only") }
  end

  test "all private endpoints require authentication" do
    [ admin_root_path(locale: :en), admin_products_path(locale: :en), admin_waitlist_signups_path(locale: :en), export_admin_waitlist_signups_path(locale: :en) ].each do |path|
      get path
      assert_response :unauthorized
    end
    get admin_root_path(locale: :en), headers: { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("researcher", "wrong") }
    assert_response :unauthorized
    ENV.delete("ADMIN_PASSWORD")
    get admin_root_path(locale: :en)
    assert_response :service_unavailable
  end

  test "authenticated dashboard and source editing render" do
    product = catalogue_product
    get admin_root_path(locale: :en), headers: credentials
    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    get edit_admin_product_path(locale: :en, id: product.slug), headers: credentials
    assert_response :success
    assert_select "input[name*='image_url']"
    patch admin_product_path(locale: :en, id: product.slug), headers: credentials, params: { product: { selected_for_first_import: "1", eu_compliance_status: "documentation_received", launch_status: "planned", product_translations_attributes: { "0" => { id: product.translation(:en).id, locale: "en", name: "Updated Pan Mee" } } } }
    assert_response :redirect
    assert product.reload.selected_for_first_import?
    assert_equal "Updated Pan Mee", product.translation(:en).name
    get admin_products_path(locale: :en), headers: credentials
    assert_response :success
  end

  test "CSV export is authenticated, includes consent and neutralizes formulas" do
    signup = subscriber(first_name: '=HYPERLINK("example")', utm_source: "instagram")
    get export_admin_waitlist_signups_path(locale: :en, format: :csv), headers: credentials
    assert_response :success
    rows = CSV.parse(response.body, headers: true)
    assert_equal signup.email, rows.first["email"]
    assert rows.first["first_name"].start_with?("'=")
    assert_equal "launch-v1", rows.first["consent_version"]
    assert_equal "instagram", rows.first["utm_source"]
    delete admin_waitlist_signup_path(locale: :en, id: signup.id), headers: credentials
    assert_response :redirect
    assert_equal 0, WaitlistSignup.count
  end
  test "admin can create and delete a product with translations and a blank source row" do
    brand = Brand.create!(slug: "manufacturer", name: "Manufacturer")
    assert_difference "Product.count", 1 do
      post admin_products_path(locale: :en), headers: credentials, params: { product: {
        name: "New source reference", slug: "new-reference", brand_id: brand.id,
        vegetarian: "", contains_animal_products: "", launch_status: "researching",
        product_translations_attributes: { "0" => { locale: "en", name: "New reference" }, "1" => { locale: "fr", name: "Nouvelle référence" } },
        product_sources_attributes: { "0" => { source_name: "", url: "", image_rights_status: "permission_required" } }
      } }
    end
    assert_response :redirect
    product = Product.find_by!(slug: "new-reference")
    assert_nil product.vegetarian
    assert_nil product.contains_animal_products
    assert_empty product.product_sources
    delete admin_product_path(locale: :en, id: product.slug), headers: credentials
    assert_response :redirect
    assert_not Product.exists?(product.id)
  end
end
