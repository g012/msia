# Aggregate request counts only: no IP, user agent, fingerprint or visitor cookie.
# Replace this adapter when choosing a reviewed privacy-friendly provider.
class AnalyticsAdapter
  def self.page_view(path:)
    PageMetric.upsert({ day: Date.current, path: path, views: 1 },
      unique_by: [ :day, :path ], on_duplicate: Arel.sql("views = page_metrics.views + 1"))
  end
end
