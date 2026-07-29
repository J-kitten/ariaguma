# config/initializers/firebase.rb

FirebaseIdToken.configure do |config|
  #config.redis = Redis.new(
  #  url: "redis://127.0.0.1:6379"
  #)
  config.project_ids = ["ariagumareact"]
  #config.project_ids = [ENV["GOOGLE_CLIENT_ID"]]

  begin
    FirebaseIdToken::Certificates.request
    Rails.logger.info "Firebase certificates loaded."
  rescue => e
    Rails.logger.error e.message
  end

end
