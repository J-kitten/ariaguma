# app/controllers/inquiries_controller.rb
class InquiriesController < ApplicationController
  layout "inquiry_layout"  # 独立したレイアウトを使う

  def new
    @inquiry = Inquiry.new
  end

  def create
    @inquiry = Inquiry.new(inquiry_params)
    if @inquiry.save
      flash[:admin_notice] = "お問い合わせ内容を送信しました。"
      redirect_to new_inquiry_path, notice: "送信に成功しました。"
    else
      flash.now[:admin_alert] = "送信内容に不備があります。"
      render :new
    end
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:name, :email, :email_confirmation, :subject, :message)
  end

  def by_email
    inquiries = Inquiry.where(email: params[:email])
    render json: inquiries
  end

end
