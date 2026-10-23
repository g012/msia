class HealthController < ActionController::Base
  def show
    ActiveRecord::Base.connection.select_value("SELECT 1")
    response.headers["Cache-Control"] = "no-store"
    head :ok
  rescue ActiveRecord::ActiveRecordError
    head :service_unavailable
  end
end
