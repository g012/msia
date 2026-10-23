class WaitlistSignupsController < ApplicationController
  rate_limit to: 8, within: 10.minutes, only: :create
  before_action :no_store

  def new
    @signup = WaitlistSignup.new(country: "FR")
    load_options
  end

  def create
    if params[:website].present?
      redirect_to thank_you_path, status: :see_other
      return
    end
    attrs = params.require(:waitlist_signup).permit(:email, :country, :consent)
    attrs.merge!(locale: I18n.locale.to_s, consented_at: Time.current, consent_version: "launch-v1", **attribution.symbolize_keys)
    @signup, result = WaitlistRegistration.call(attributes: attrs, product_ids: params[:product_ids], category_ids: params[:category_ids], visitor_key: session[:interest_key])
    if result == :invalid
      load_options
      render :new, status: :unprocessable_entity
    else
      @preference_token = @signup&.management_token
      session[:preference_token] = @preference_token if @preference_token
      redirect_to thank_you_path, status: :see_other
    end
  end

  def thank_you
    @signup = WaitlistSignup.find_signed(session[:preference_token], purpose: :preferences) if session[:preference_token]
    @preference_token = session[:preference_token]
    load_options if @signup
  end

  private

  def load_options
    @products = Product.visible.with_catalogue.order(:id)
    @categories = Category.order(:id)
    @selected_products = Array(params[:product_ids]).map(&:to_i).presence || (interest_ids + [ params[:product].to_i ]).uniq
  end

  def no_store
    response.headers["Cache-Control"] = "no-store"
    response.headers["X-Robots-Tag"] = "noindex"
  end
end
