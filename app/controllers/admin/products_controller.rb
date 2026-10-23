module Admin
  class ProductsController < BaseController
    before_action :find_product, only: [ :edit, :update, :destroy ]

    def index
      @products = Product.with_catalogue.order(:id)
    end

    def new
      @product = Product.new
      build_translations
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to edit_admin_product_path(@product), notice: "Product created."
      else
        build_translations
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      build_translations
    end

    def update
      if @product.update(product_params)
        redirect_to edit_admin_product_path(@product), notice: "Product saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy!
      redirect_to admin_products_path, status: :see_other, notice: "Product deleted."
    end

    private

    def find_product
      @product = Product.find_by!(slug: params[:id])
    end

    def build_translations
      @product.product_sources.build
      %w[fr en].each { |locale| @product.product_translations.build(locale: locale) unless @product.product_translations.any? { |tr| tr.locale == locale } }
    end

    def product_params
      params.require(:product).permit(:name, :slug, :brand_id, :supplier_id, :sku, :net_weight, :pack_size, :manufacturer, :country_of_origin,
        :ingredients, :allergens, :nutrition, :preparation, :shelf_life, :vegetarian, :contains_animal_products, :spicy, :dietary_evidence,
        :halal_status, :eu_compliance_status, :launch_status, :official_source_url, :photo, :illustration, :featured, :selected_for_first_import,
        category_ids: [], product_translations_attributes: [ :id, :locale, :name, :short_description, :description, :origin, :ingredients, :allergens, :nutrition, :preparation, :regulated_reviewed, :_destroy ],
        product_sources_attributes: [ :id, :source_name, :url, :image_url, :image_rights_status, :confirmed_facts, :unknown_facts, :checked_at, :_destroy ])
    end
  end
end
