module Admin
  class DashboardController < BaseController
    def show
      @total = WaitlistSignup.active.count
      @confirmed = WaitlistSignup.confirmed.count
      @days = WaitlistSignup.active.group("DATE(created_at)").order(Arel.sql("DATE(created_at)")).count
      @countries = WaitlistSignup.active.group(:country).order(count_all: :desc).count
      @postcodes = WaitlistSignup.active.where(country: "FR").where.not(postcode: [ nil, "" ]).group(:postcode).order(count_all: :desc).count
      @products = Product.with_catalogue.order(:id)
      @interest = ProductInterest.group(:product_id).count
      @confirmed_interest = ProductInterest.joins(:waitlist_signup).merge(WaitlistSignup.confirmed).group(:product_id).count
      category_names = Category.pluck(:id, :name_en).to_h
      @categories = DemandReport.category_counts.sort_by { |_, count| -count }.to_h.transform_keys { |id| category_names.fetch(id) }
      @acquisition = WaitlistSignup.active.group(:utm_source, :utm_medium, :utm_campaign, :utm_content).count
      @views = PageMetric.group(:path).sum(:views)
      @conversions = WaitlistSignup.confirmed.group(:landing_page).count
    end
  end
end
