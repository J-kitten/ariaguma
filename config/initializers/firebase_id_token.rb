#config/initializers/firebase_id_token.rb

FirebaseIdToken.configure do |config|
  config.redis = Redis.new(url: "redis://127.0.0.1:6379")
  config.project_ids = ['ariagumareact']
  #config.project_ids = ['YOUR_FIREBASE_PROJECT_ID']
end
