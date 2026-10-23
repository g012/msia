class PagesController < ApplicationController
  after_action :track_page, only: [ :home, :landing ]

  def home
    @products = Product.visible.with_catalogue.where(featured: true).order(:id).limit(4)
    @categories = Category.order(:id)
    @category_popularity = DemandReport.category_counts(confirmed: true)
    @popularity = ProductInterest.joins(:product, :waitlist_signup).merge(Product.visible).merge(WaitlistSignup.confirmed).group(:product_id).count
    @signup = WaitlistSignup.new
  end

  def show
    @page = params[:page]
    raise ActiveRecord::RecordNotFound unless @page.in?(%w[about faq privacy legal])
  end

  def landing
    @topic = params[:topic]
    @products = Product.visible.with_catalogue
    @products = @products.joins(:categories).where(categories: { slug: @topic }) if @topic.in?(%w[pan-mee kolo-mee])
    @products = @products.limit(6)
  end
end
