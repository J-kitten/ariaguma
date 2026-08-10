# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#     policy.style_src   :self, :https
#     # Specify URI for violation reports
#     # policy.report_uri "/csp-violation-report-endpoint"
#   end
#
#   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src style-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
# end

# config/initializers/content_security_policy.rb

Rails.application.config.content_security_policy do |policy|
  # --- 基本 ---
  policy.default_src :self

  # --- Script ---
  policy.script_src :self,
                    :unsafe_inline,  # inline script許可（まず動かす目的）
                    "https://cdn.jsdelivr.net",
                    "https://apis.google.com",
                    "https://www.gstatic.com",
                    "https://www.googletagmanager.com",
                    "https://www.google-analytics.com",
                    "https://www.googleapis.com"

  # --- Style ---
  policy.style_src :self,
                   :unsafe_inline, # inline style許可
                   "https://cdn.jsdelivr.net",
                   "https://fonts.googleapis.com"

  # --- Font ---
  policy.font_src :self,
                  "https://fonts.gstatic.com",
                  "https://cdn.jsdelivr.net",
                  "data:"

  # --- Image ---
  policy.img_src :self, "data:", "https://www.google-analytics.com"

  # --- Ajax / fetch / API 通信 ---
  policy.connect_src :self,
                     "https://identitytoolkit.googleapis.com",
                     "https://securetoken.googleapis.com",
                     "https://www.googleapis.com",
                     "https://firebase.googleapis.com",
                     "https://www.googletagmanager.com",
                     "https://www.google-analytics.com",
                     "https://fonts.googleapis.com",
                     "https://fonts.gstatic.com"

  # --- iframe（必要な場合のみ）---
  policy.frame_src :self, 
                    "https://www.gstatic.com", 
                    "https://*.firebaseapp.com", 
                    "https://accounts.google.com"

  # --- Base URI ---
  policy.base_uri :self
end
