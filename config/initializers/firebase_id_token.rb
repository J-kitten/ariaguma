# config/initializers/firebase_id_token.rb

FirebaseIdToken.configure do |config|
  config.redis = Redis.new(
    url: ENV.fetch(
      "REDIS_URL",
      "redis://127.0.0.1:6379/0"
    )
  )

  config.project_ids = [
    ENV.fetch(
      "FIREBASE_PROJECT_ID",
      "ariagumareact"
    )
  ]
end
