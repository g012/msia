class ProductsController < ApplicationController
  after_action :track_page, only: [ :index, :show ]

  def index
    @categories = Category.order(:id)
    @brands = Brand.order(:name)
    @products = Product.visible.with_catalogue.order(:id)
    @products = @products.joins(:categories).where(categories: { slug: params[:category] }) if params[:category].present?
    @products = @products.where(brand_id: params[:brand]) if params[:brand].present?
    @products = @products.where(vegetarian: true) if params[:diet] == "vegetarian"
    @products = @products.where(contains_animal_products: true) if params[:diet] == "animal"
    @products = @products.where(spicy: params[:spicy] == "yes") if params[:spicy].in?(%w[yes no])
    @products = @products.distinct
  end

  def show
    @product = Product.visible.with_catalogue.find_by!(slug: params[:id])
  end
end
