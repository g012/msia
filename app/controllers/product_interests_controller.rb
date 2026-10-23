class ProductInterestsController < ApplicationController
  rate_limit to: 30, within: 5.minutes, only: :create

  def create
    product = Product.visible.find_by!(slug: params[:product_id])
    session[:interest_key] ||= SecureRandom.hex(24)
    ProductInterest.create_or_find_by!(product: product, visitor_key: session[:interest_key])
    session[:interest_ids] = (interest_ids + [ product.id ]).uniq.last(30)
    redirect_to new_waitlist_signup_path(product: product.id), status: :see_other, notice: t("waitlist.interest_saved")
  end
end
