Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.font_src :self
  policy.img_src :self, :data, :blob
  policy.object_src :none
  policy.script_src :self
  policy.style_src :self, :unsafe_inline
  policy.connect_src :self
  policy.base_uri :self
  policy.form_action :self
  policy.frame_ancestors :none
end
Rails.application.config.content_security_policy_nonce_generator = ->(request) { request.env["msia.csp_nonce"] ||= SecureRandom.base64(16) }
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]
