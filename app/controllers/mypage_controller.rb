# app/controllers/mypage_controller.rb
class MypageController < ApplicationController
  before_action :require_login

  def show
    @user = current_user

    @contacts = Contact.where(email_hash: @user.email_hash)
                       .where(trash: false)
                       .order(created_at: :desc)

    @regists = Regist.where(email_hash: @user.email_hash)
                     .order(created_at: :desc)
    @replies = Reply.where(email_hash: @user.email_hash, trash: false)

    @download_files_by_volume = 
               DownloadFile.order(:sort_order, :id)
                     .index_by { |download_file| download_file.volume.to_i }

    @histories =
      @contacts.map do |contact|
        {
          type: :contact,
          data: contact,
          created_at: contact.created_at
        }
      end +
      @replies.map do |reply|
        {
          type: :reply,
          data: reply,
          created_at: reply.created_at
        }
      end

    @histories.sort_by! { |history| history[:created_at] }.reverse!
  end

  def contact_show
    @user = current_user
    @contact = Contact.where(email_hash: @user.email_hash, trash: false)
                      .find(params[:id])
  end

  def contact_reply
    @user = current_user
    @contact = Contact.where(email_hash: @user.email_hash, trash: false)
                      .find(params[:id])

    Reply.create!(
      name: @contact.name,
      subject: "RE: " + @contact.subject,
      email_hash: @user.email_hash,
      message: params[:message],
      contact_id: @contact.id
    )

    redirect_to mypage_contact_path(@contact), notice: "返信を送信しました。"
  end

  def reply_show
    @user = current_user

    @reply = Reply.find_by(
      id: params[:id],
      email_hash: @user.email_hash,
      trash: false
    )

    unless @reply
      redirect_to mypage_path, alert: "返信履歴が見つかりませんでした。"
    end
  end

  def reply_reply
    @user = current_user

    @reply = Reply.find_by!(
      id: params[:id],
      email_hash: @user.email_hash,
      trash: false
    )

    Reply.create!(
      name: @reply.name,
      subject: "RE: #{@reply.subject}",
      email_hash: @user.email_hash,
      message: params[:message],
      contact_id: @reply.contact_id,
      regist_id: @reply.regist_id
    )

    redirect_to mypage_path, notice: "返信を送信しました。"
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login
    redirect_to root_path, alert: "ログインしてください。" unless current_user
  end

end
