class UsersController < ApplicationController
  layout "management"

  def new
    @user = User.new
  end

  def me
    render json: {
      user: current_user
    }
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in(@user)  # 登録と同時にログイン
      redirect_to management_screen_path, notice: "登録が完了しました。"
    else
      flash.now[:alert] = "登録に失敗しました。"
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
