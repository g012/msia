class LocalesController < ActionController::Base
  def show
    preferred = request.env["HTTP_ACCEPT_LANGUAGE"].to_s.split(",").map { |part| part.split(";").first.to_s.split("-").first }
    locale = preferred.find { |code| code.in?(%w[fr en]) } || "fr"
    redirect_to localized_root_path(locale: locale, **params.permit(:utm_source, :utm_medium, :utm_campaign, :utm_content).to_h), status: :found
  end
end
