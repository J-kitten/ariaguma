class ManagementScreen::DownloadLogsController <
      ManagementScreen::BaseController
  layout "management"

  before_action :set_download_log,
                only: :show

  def index
    # --------------------------------
    # 集計
    # --------------------------------

    @today_count =
      DownloadLog.where(
        downloaded_at: Time.zone.today.all_day
      ).count

    @month_count =
      DownloadLog.where(
        downloaded_at:
          Time.zone.now.beginning_of_month..
          Time.zone.now.end_of_month
      ).count

    @total_count =
      DownloadLog.count

    @unique_regist_count =
      DownloadLog
        .where.not(regist_id: nil)
        .distinct
        .count(:regist_id)

    # --------------------------------
    # 書籍選択肢
    # --------------------------------

    @download_files =
      DownloadFile.order(
        sort_order: :asc,
        id: :asc
      )

    # --------------------------------
    # 履歴一覧
    # --------------------------------

    @download_logs =
      DownloadLog
        .includes(
          :download_file,
          :regist
        )
        .order(
          downloaded_at: :desc
        )

    # --------------------------------
    # 期間：開始日
    # --------------------------------

    if params[:date_from].present?
      date_from =
        Time.zone.parse(
          params[:date_from]
        ).beginning_of_day

      @download_logs =
        @download_logs.where(
          "download_logs.downloaded_at >= ?",
          date_from
        )
    end

    # --------------------------------
    # 期間：終了日
    # --------------------------------

    if params[:date_to].present?
      date_to =
        Time.zone.parse(
          params[:date_to]
        ).end_of_day

      @download_logs =
        @download_logs.where(
          "download_logs.downloaded_at <= ?",
          date_to
        )
    end

    # --------------------------------
    # 書籍
    # --------------------------------

    if params[:download_file_id].present?
      @download_logs =
        @download_logs.where(
          download_file_id:
            params[:download_file_id]
        )
    end

    # --------------------------------
    # 予約者名
    # --------------------------------

    if params[:regist_name].present?
      keyword =
        ActiveRecord::Base.sanitize_sql_like(
          params[:regist_name]
        )

      @download_logs =
        @download_logs
          .joins(:regist)
          .where(
            "regists.name LIKE ?",
            "%#{keyword}%"
          )
    end

    # --------------------------------
    # メールアドレス
    # --------------------------------

    if params[:email].present?
      keyword =
        ActiveRecord::Base.sanitize_sql_like(
          params[:email]
        )

      @download_logs =
        @download_logs
          .joins(:regist)
          .where(
            "regists.email LIKE ?",
            "%#{keyword}%"
          )
    end

    # --------------------------------
    # IPアドレス
    # --------------------------------

    if params[:ip_address].present?
      keyword =
        ActiveRecord::Base.sanitize_sql_like(
          params[:ip_address]
        )

      @download_logs =
        @download_logs.where(
          "download_logs.ip_address LIKE ?",
          "%#{keyword}%"
        )
    end

    # 表示件数
    @download_logs =
      @download_logs.limit(500)
  rescue ArgumentError => e
    Rails.logger.error(
      "DOWNLOAD LOG SEARCH ERROR: #{e.message}"
    )

    redirect_to(
      management_screen_download_logs_path,
      alert: "入力された期間が正しくありません。"
    )
  end

  #def index
  #  @download_logs =
  #    DownloadLog
  #      .includes(
  #        :download_file,
  #        :regist
  #      )
  #      .order(downloaded_at: :desc)
  #      #.page(params[:page]) #kaminari
  #      #.per(50)
  #end

  def show
  end

  private

  def set_download_log
    @download_log =
      DownloadLog
        .includes(
          :download_file,
          :regist
        )
        .find(params[:id])
  end
end