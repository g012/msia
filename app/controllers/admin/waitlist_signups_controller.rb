require "csv"

module Admin
  class WaitlistSignupsController < BaseController
    def index
      @signups = WaitlistSignup.includes(:products, :categories).order(created_at: :desc).limit(200)
    end

    def export
      rows = CSV.generate do |csv|
        csv << %w[email country first_name postcode locale confirmed_at consented_at consent_version unsubscribed_at products categories import_wish utm_source utm_medium utm_campaign utm_content landing_page created_at]
        WaitlistSignup.includes(:products, :categories).find_each do |signup|
          values = [ signup.email, signup.country, signup.first_name, signup.postcode, signup.locale, signup.confirmed_at, signup.consented_at, signup.consent_version, signup.unsubscribed_at,
            signup.products.map(&:name).join(" | "), signup.categories.map(&:name_en).join(" | "), signup.import_wish, signup.utm_source, signup.utm_medium, signup.utm_campaign, signup.utm_content, signup.landing_page, signup.created_at ]
          csv << values.map { |value| safe_csv(value) }
        end
      end
      send_data rows, filename: "msia-waitlist-#{Date.current}.csv", type: "text/csv; charset=utf-8"
    end

    def destroy
      WaitlistSignup.find(params[:id]).destroy!
      redirect_to admin_waitlist_signups_path, status: :see_other, notice: "Personal data erased."
    end

    private

    def safe_csv(value)
      text = value.to_s
      text.match?(/\A[=+@\t\r-]/) ? "'#{text}" : text
    end
  end
end
