class ApplicationController < ActionController::Base
  around_action :with_locale
  before_action :prepare_attribution
  helper_method :attribution, :interest_ids

  def default_url_options
    { locale: I18n.locale, ref: @attribution_token }.compact
  end

  private

  def with_locale(&action)
    I18n.with_locale(params[:locale].presence || I18n.default_locale, &action)
  end

  def prepare_attribution
    return if controller_path.start_with?("admin/")
    @attribution = Rails.application.message_verifier(:attribution).verified(params[:ref].to_s, purpose: :attribution) || {}
    if @attribution.empty?
      @attribution = params.permit(:utm_source, :utm_medium, :utm_campaign, :utm_content).to_h.transform_values { |v| v.to_s.first(200) }
      @attribution["landing_page"] = request.path.first(200)
      @attribution_token = Rails.application.message_verifier(:attribution).generate(@attribution, purpose: :attribution, expires_in: 2.hours)
    else
      @attribution_token = params[:ref]
    end
  end

  def attribution
    @attribution || {}
  end

  def interest_ids
    session[:interest_ids] || []
  end

  def track_page
    AnalyticsAdapter.page_view(path: request.path) if request.get? && !request.headers["Turbo-Frame"]
  end
end
