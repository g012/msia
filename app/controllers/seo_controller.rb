class SeoController < ActionController::Base
  def sitemap
    @products = Product.visible.order(:id)
    response.headers["Cache-Control"] = "public, max-age=3600"
  end

  def robots
    render plain: "User-agent: *\nDisallow: /fr/admin\nDisallow: /en/admin\nDisallow: /*/preferences\nDisallow: /*/unsubscribe\nDisallow: /*/confirm\nSitemap: #{ENV.fetch('APP_URL', 'http://localhost:3000')}/sitemap.xml\n"
  end
end
