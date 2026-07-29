class RegistsController < ApplicationController
  before_action :set_regist, only: [:show, :update_subscription]

  def show
    @regist.Regist.new
  end

  def  update_subscription
    if params[:subscribed] == "true"
      @regist.update(subscribed: true)
    elsif params[:subscribed] == "false"
      @regist.update(subscribed: false)
    end
    redirect_to regist_path(@regist)
  end

  def create
    regist_params = params.require(:regist).permit(:name, :email, :email_confirmation, :email_sent_01, :email_sent_02, :subscribed)

    # メールアドレス確認チェック
    unless regist_params[:email] == regist_params[:email_confirmation]
      flash.now[:admin_alert] = "メールアドレスが一致しません。 regists_controller.rb"
      @regist = Regist.new(regist_params.except(:email_confirmation))
      return render :index
    end

    @regist = Regist.new(
      name: regist_params[:name],
      email: regist_params[:email],
      subscribed: false,
      email_sent_01: NULL,
      email_sent_02: NULL
    )

    if @regist.save
      flash[:admin_notice] = "Present電子書籍『死闘の死闘』が完成しましたら、登録予約されましたメールアドレス宛に、メールをお送りします。<br>また、ご登録内容の確認メールもお送りしていますので、ご確認ください。regists_controller.rb"
      redirect_to root_path
    else
      flash.now[:admin_alert] = "メールアドレスが重複しているため予約登録ができません。regists_controller.rb"
      render 'home/index'
    end

  rescue ActiveRecord::RecordNotUnique
    # 重複登録保険（例外発生時もフォームに戻してエラーを表示）
    logger.debug "★★ rescue RecordNotUnique に入りました ★★"
    @regist ||= Regist.new(regist_params.except(:email_confirmation))
    @regist.errors.add(:email, "はすでに予約登録されています regists_controller.rb")
    flash.now[:admin_alert] = "このメールアドレスはすでに予約登録されています。regists_controller.rb"
    render 'home/index'
  end

  def index
    @regists = Regist.all
    @regists = @regists.where("email LIKE ?", "%#{params[:email]}%") if params[:email].present?
    @regists = @regists.where(email_sent_01: '未送信') if params[:unsent] == "1"
    @regists = @regists.where(subscribed: true) if params[:subscribed] == "1"
  end

  def complete
  end

  private

  def set_regist
    @regist = Regist.find(params[:id])
  end

end

