require "json"

brand = Brand.find_or_create_by!(slug: "hock-kee-kopitiam") { |b| b.name = "Hock Kee Kopitiam"; b.official_url = "https://www.hockkeegroup.com/" }
supplier = Supplier.find_or_create_by!(name: "Hock Kee Group — prospective supplier") do |s|
  s.official_url = "https://www.hockkeegroup.com/"
  s.notes = "Research lead only. No commercial relationship, export eligibility or legal manufacturing identity confirmed."
end
[
  [ "pan-mee", "Pan Mee", "Pan Mee", "noodles" ], [ "kolo-mee", "Kolo Mee", "Kolo Mee", "noodles" ],
  [ "noodles", "Autres nouilles", "Other noodles", "noodles" ], [ "coffee", "Café malaisien", "Malaysian coffee", "coffee" ],
  [ "tea", "Thé & milk tea", "Tea & milk tea", "tea" ], [ "snacks", "Biscuits & snacks", "Biscuits & snacks", "snacks" ],
  [ "kaya", "Kaya", "Kaya", "pantry" ], [ "sauces", "Sauces & pâtes de curry", "Sauces & curry pastes", "pantry" ],
  [ "teh-tarik", "Teh tarik", "Teh tarik", "tea" ]
].each do |slug, fr, en, illustration|
  Category.find_or_create_by!(slug: slug) { |c| c.name_fr = fr; c.name_en = en; c.illustration = illustration }
end
JSON.parse(Rails.root.join("data/hock_kee_products.json").read).each_with_index do |row, index|
  # Seeds create missing records; rerunning never overwrites administrative edits.
  next if Product.exists?(slug: row.fetch("slug"))
  Product.transaction do
    product = Product.create!(row.slice("name", "slug", "illustration", "vegetarian", "spicy", "contains_animal_products", "pack_size", "net_weight", "preparation", "official_source_url").merge(
      brand: brand, supplier: supplier, launch_status: "candidate", eu_compliance_status: "investigating", featured: index < 4,
      dietary_evidence: row["vegetarian"] ? "Official manufacturer product name labels this variant Vegetarian. Full ingredient / allergen declaration still unverified." : nil))
    product.categories << Category.find_by!(slug: row.fetch("category"))
    row.fetch("translations").each { |locale, translation| product.product_translations.create!(translation.merge(locale: locale, regulated_reviewed: false)) }
    product.product_sources.create!(source_name: "Hock Kee Kopitiam — official catalogue", url: row.fetch("official_source_url"), image_url: row.fetch("image_url"), image_rights_status: "permission_required", confirmed_facts: row.fetch("confirmed_facts"), unknown_facts: "Full composition; complete allergens; nutrition; shelf life; exact manufacturer; country of manufacture; product halal certificates; EU import eligibility; image reproduction permission.", checked_at: Time.utc(2026, 10, 23))
    product.product_sources.create!(source_name: "Hock Kee — public catalogue product record", url: row.fetch("source_api_url"), image_rights_status: "permission_required", confirmed_facts: row.fetch("confirmed_facts"), checked_at: Time.utc(2026, 10, 23))
  end
end
puts "Catalogue ready: #{Product.count} products, #{Category.count} categories. No fake subscribers or votes seeded."
