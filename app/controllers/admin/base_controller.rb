module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin
    before_action do
      response.headers["Cache-Control"] = "no-store"
      response.headers["X-Robots-Tag"] = "noindex, nofollow"
    end
    layout "admin"

    private

    def authenticate_admin
      username = ENV["ADMIN_USERNAME"].to_s
      password = ENV["ADMIN_PASSWORD"].to_s
      return head :service_unavailable if username.empty? || password.empty?
      authenticate_or_request_with_http_basic("MSIA private admin") do |given_user, given_password|
        ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(given_user), Digest::SHA256.hexdigest(username)) &
          ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(given_password), Digest::SHA256.hexdigest(password))
      end
    end
  end
end
