if Rails.env.production? && ENV["SECRET_KEY_BASE_DUMMY"].blank?
  required = %w[SECRET_KEY_BASE DATABASE_URL APP_URL ADMIN_USERNAME ADMIN_PASSWORD SMTP_HOST SMTP_USERNAME SMTP_PASSWORD MAIL_FROM]
  missing = required.select { |name| ENV[name].blank? }
  raise "Missing production environment variables: #{missing.join(', ')}" if missing.any?
  raise "APP_URL must use HTTPS" unless URI(ENV.fetch("APP_URL")).scheme == "https"
  raise "ADMIN_PASSWORD must have at least 24 characters" if ENV.fetch("ADMIN_PASSWORD").length < 24
end
