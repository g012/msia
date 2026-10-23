Rails.application.routes.draw do
  get "up" => "health#show", as: :rails_health_check
  get "sitemap.xml" => "seo#sitemap", defaults: { format: :xml }
  get "robots.txt" => "seo#robots", defaults: { format: :text }
  root "locales#show"
  scope ":locale", locale: /fr|en/ do
    root "pages#home", as: :localized_root
    resources :products, only: [ :index, :show ] do
      resources :interests, only: :create, controller: "product_interests"
    end
    resources :waitlist_signups, only: [ :new, :create ], path: "waitlist"
    get "thank-you" => "waitlist_signups#thank_you", as: :thank_you
    get "confirm" => "subscriptions#confirm", as: :confirmation
    post "confirm" => "subscriptions#activate"
    get "unsubscribe" => "subscriptions#unsubscribe", as: :unsubscribe
    post "unsubscribe" => "subscriptions#destroy"
    get "preferences" => "subscriptions#edit", as: :preferences
    patch "preferences" => "subscriptions#update"
    get ":page" => "pages#show", constraints: { page: /about|faq|privacy|legal/ }, as: :page
    get ":topic" => "pages#landing", constraints: { topic: /epicerie-malaisienne|nouilles-malaisiennes|pan-mee|kolo-mee|kopitiam/ }, as: :landing
    namespace :admin do
      root "dashboard#show"
      resources :products, except: :show
      resources :waitlist_signups, only: [ :index, :destroy ] do
        get :export, on: :collection
      end
    end
  end
end
