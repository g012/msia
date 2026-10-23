xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
base = ENV.fetch("APP_URL", "http://localhost:3000").delete_suffix("/")
xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
  %w[fr en].each do |locale|
    [ "", "/products", "/about", "/faq", "/epicerie-malaisienne", "/nouilles-malaisiennes", "/pan-mee", "/kolo-mee", "/kopitiam" ].each do |path|
      xml.url { xml.loc "#{base}/#{locale}#{path}" }
    end
    @products.each do |product|
      xml.url do
        xml.loc "#{base}/#{locale}/products/#{product.slug}"
        xml.lastmod product.updated_at.iso8601
      end
    end
  end
end
