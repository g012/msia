module ApplicationHelper
  def page_title
    @title.presence || t("seo.title")
  end

  def canonical_url
    base = ENV.fetch("APP_URL", "http://localhost:3000").delete_suffix("/")
    base + request.path
  end

  def localized_switch_path(locale)
    options = request.path_parameters.merge(locale: locale, only_path: true, ref: @attribution_token)
    options[:token] = params[:token] if controller_name == "subscriptions"
    url_for(options)
  rescue ActionController::UrlGenerationError
    localized_root_path(locale: locale, ref: nil)
  end

  def country_options
    names = {
      "FR" => [ "France", "France" ], "BE" => [ "Belgique", "Belgium" ], "DE" => [ "Allemagne", "Germany" ], "NL" => [ "Pays-Bas", "Netherlands" ],
      "ES" => [ "Espagne", "Spain" ], "IT" => [ "Italie", "Italy" ], "LU" => [ "Luxembourg", "Luxembourg" ], "AT" => [ "Autriche", "Austria" ],
      "IE" => [ "Irlande", "Ireland" ], "PT" => [ "Portugal", "Portugal" ], "DK" => [ "Danemark", "Denmark" ], "SE" => [ "Suède", "Sweden" ],
      "FI" => [ "Finlande", "Finland" ], "PL" => [ "Pologne", "Poland" ], "CZ" => [ "Tchéquie", "Czechia" ], "GR" => [ "Grèce", "Greece" ],
      "RO" => [ "Roumanie", "Romania" ], "HU" => [ "Hongrie", "Hungary" ], "BG" => [ "Bulgarie", "Bulgaria" ], "HR" => [ "Croatie", "Croatia" ],
      "SI" => [ "Slovénie", "Slovenia" ], "SK" => [ "Slovaquie", "Slovakia" ], "EE" => [ "Estonie", "Estonia" ], "LV" => [ "Lettonie", "Latvia" ],
      "LT" => [ "Lituanie", "Lithuania" ], "CY" => [ "Chypre", "Cyprus" ], "MT" => [ "Malte", "Malta" ], "OTHER" => [ "Autre pays", "Other country" ]
    }
    names.map { |code, pair| [ pair[I18n.locale == :fr ? 0 : 1], code ] }
  end

  def arrow
    tag.span("↗", aria: { hidden: true }, class: "arrow")
  end

  def product_visual(product, eager: false)
    if product.photo.attached?
      image_tag product.photo, alt: product.display_name, width: 600, height: 480, loading: eager ? "eager" : "lazy", class: "product-photo"
    else
      image_tag "#{product.illustration}.svg", alt: "", width: 600, height: 480, loading: eager ? "eager" : "lazy", class: "product-photo"
    end
  end

  def interest_button(product, class_name: "interest-button")
    button_to product_interests_path(product), class: class_name do
      safe_join([ tag.span("+", aria: { hidden: true }), tag.span(t("product.interest")) ], " ")
    end
  end
end
