module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_account, :logged_in?
  end

  def current_account
    return @current_account if defined?(@current_account)

    token = request.headers["Authorization"]&.split(" ")&.last
    return nil unless token

    payload = FirebaseIdToken::Signature.verify(token)

    @current_account = Account.find_by(email: payload["email"])
  rescue
    @current_account = nil
  end

  def logged_in?
    current_account.present?
  end

  def authenticate!
    render json: { error: "unauthorized" }, status: 401 unless logged_in?
  end
end