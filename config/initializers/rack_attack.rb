class Rack::Attack
  # ****************************************
  # Firebaseログインのレート制限
  #
  # 同一IPから
  # POST /firebase_login
  # 1分間10回まで
  # ****************************************
  throttle(
    "firebase_login/ip",
    limit: 10,
    period: 1.minute
  ) do |req|
    req.ip if req.post? &&
              req.path == "/firebase_login"
  end

  self.throttled_responder = lambda do |_request|
    [
      429,
      {
        "Content-Type" =>
          "application/json; charset=utf-8"
      },
      [
        {
          success: false,
          error:
            "ログイン試行回数が多すぎます。" \
            "しばらく時間を置いてから再度お試しください。"
        }.to_json
      ]
    ]
  end

  # ****************************************
  # 制限超過時
  # HTTP 429 Too Many Requests
  # ****************************************
  self.throttled_responder = lambda do |request|
    match_data =
      request.env["rack.attack.match_data"]

    retry_after =
      match_data &&
      match_data[:period]

    [
      429,
      {
        "Content-Type" => "application/json; charset=utf-8",
        "Retry-After" =>
          (retry_after || 60).to_s
      },
      [
        {
          success: false,
          error:
            "ログイン試行回数が多すぎます。" \
            "しばらく時間を置いてから再度お試しください。"
        }.to_json
      ]
    ]
  end
end