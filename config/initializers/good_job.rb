Rails.application.configure do
  config.good_job.enable_cron = ENV["GOOD_JOB_ENABLE_CRON"] == "true"
  config.good_job.cron = { privacy_retention: { cron: "0 3 * * * Europe/Paris", class: "RetentionJob" } }
  config.good_job.preserve_job_records = false
end
