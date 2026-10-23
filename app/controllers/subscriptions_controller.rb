class SubscriptionsController < ApplicationController
  before_action :private_response
  before_action :find_signup

  def confirm
  end

  def activate
    @signup.update!(confirmed_at: Time.current) unless @signup.unsubscribed_at? || @signup.confirmed_at?
    redirect_to confirmation_path(token: params[:token]), status: :see_other
  end

  def unsubscribe
  end

  def destroy
    @signup.with_lock do
      @signup.update!(unsubscribed_at: Time.current)
      @signup.product_interests.destroy_all
      @signup.waitlist_category_interests.destroy_all
    end
    render :unsubscribed
  end

  def edit
    @products = Product.visible.with_catalogue.order(:id)
    @categories = Category.order(:id)
  end

  def update
    return head :gone if @signup.unsubscribed_at?
    @signup.with_lock do
      @signup.update!(params.require(:waitlist_signup).permit(:first_name, :postcode, :connection_to_malaysia, :import_wish))
      @signup.categories = Category.where(id: params[:category_ids])
      selected = Product.visible.where(id: params[:product_ids])
      @signup.product_interests.where.not(product_id: selected.select(:id)).destroy_all
      selected.each do |product|
        @signup.product_interests.find_or_create_by!(product: product, visitor_key: "signup:#{@signup.id}")
      end
    end
    redirect_to preferences_path(token: params[:token]), status: :see_other, notice: t("waitlist.preferences_saved")
  rescue ActiveRecord::RecordInvalid
    edit
    render :edit, status: :unprocessable_entity
  end

  private

  def private_response
    response.headers["Cache-Control"] = "no-store"
    response.headers["Referrer-Policy"] = "no-referrer"
    response.headers["X-Robots-Tag"] = "noindex, nofollow"
  end

  def find_signup
    purpose = case action_name
    when "confirm", "activate" then :confirmation
    when "unsubscribe", "destroy" then :unsubscribe
    else :preferences
    end
    @signup = WaitlistSignup.find_signed!(params[:token], purpose: purpose)
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    render plain: t("waitlist.invalid_link"), status: :not_found
  end
end
