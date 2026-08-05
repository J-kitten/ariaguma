# app/controllers/management_screen/download_files_controller.rb
class ManagementScreen::DownloadFilesController <
      ManagementScreen::BaseController
  layout 'management'

  before_action :set_download_file,
                only: %i[show edit update destroy]

  MAX_PDF_SIZE = 20_000.kilobytes # 20MB位

  def index
    @download_files =
      DownloadFile.order(sort_order: :asc, id: :desc)
  end

  def show
  end

  def new
    @download_file = DownloadFile.new(
      volume: 1,
      download_limit: 50,
      download_count: 0,
      published: false,
      sort_order: 0
    )
  end

  def create
    @download_file =
      DownloadFile.new(download_file_attributes)

    uploaded_file = uploaded_pdf

    unless uploaded_file.present?
      @download_file.errors.add(
        :pdf_file,
        "を選択してください"
      )

      render :new, status: :unprocessable_entity
      return
    end

    unless valid_pdf?(uploaded_file)
      render :new, status: :unprocessable_entity
      return
    end

    saved_absolute_path = nil

    begin
      stored_filename = generate_stored_filename
      relative_path = "/downloads/#{stored_filename}"

      saved_absolute_path =
        Rails.root.join(
          "public",
          "downloads",
          stored_filename
        )

      FileUtils.mkdir_p(saved_absolute_path.dirname)

      FileUtils.cp(
        uploaded_file.tempfile.path,
        saved_absolute_path
      )

      @download_file.filename =
        sanitize_original_filename(
          uploaded_file.original_filename
        )

      @download_file.path = relative_path
      @download_file.file_size = uploaded_file.size
      @download_file.content_type = "application/pdf"
      @download_file.download_count = 0

      @download_file.save!

      redirect_to(
        management_screen_download_files_path,
        notice: "PDFファイルを登録しました。"
      )
    rescue ActiveRecord::RecordInvalid
      FileUtils.rm_f(saved_absolute_path) if saved_absolute_path

      render :new, status: :unprocessable_entity
    rescue StandardError => e
      FileUtils.rm_f(saved_absolute_path) if saved_absolute_path

      Rails.logger.error(
        "[DownloadFile upload error] " \
        "#{e.class}: #{e.message}"
      )

      @download_file.errors.add(
        :base,
        "PDFファイルの保存に失敗しました。"
      )

      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    uploaded_file = uploaded_pdf

    if uploaded_file.present? && !valid_pdf?(uploaded_file)
      render :edit, status: :unprocessable_entity
      return
    end

    old_absolute_path = @download_file.absolute_file_path
    new_absolute_path = nil

    begin
      @download_file.assign_attributes(
        download_file_attributes
      )

      if uploaded_file.present?
        stored_filename = generate_stored_filename
        relative_path = "/downloads/#{stored_filename}"

        new_absolute_path =
          Rails.root.join(
            "public",
            "downloads",
            stored_filename
          )

        FileUtils.mkdir_p(new_absolute_path.dirname)

        FileUtils.cp(
          uploaded_file.tempfile.path,
          new_absolute_path
        )

        @download_file.filename =
          sanitize_original_filename(
            uploaded_file.original_filename
          )

        @download_file.path = relative_path
        @download_file.file_size = uploaded_file.size
        @download_file.content_type = "application/pdf"
      end

      @download_file.save!

      if uploaded_file.present? &&
         old_absolute_path != new_absolute_path

        FileUtils.rm_f(old_absolute_path)
      end

      redirect_to(
        management_screen_download_files_path,
        notice: "ファイル情報を更新しました。"
      )
    rescue ActiveRecord::RecordInvalid
      FileUtils.rm_f(new_absolute_path) if new_absolute_path

      render :edit, status: :unprocessable_entity
    rescue StandardError => e
      FileUtils.rm_f(new_absolute_path) if new_absolute_path

      Rails.logger.error(
        "[DownloadFile update error] " \
        "#{e.class}: #{e.message}"
      )

      @download_file.errors.add(
        :base,
        "ファイル情報の更新に失敗しました。"
      )

      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    absolute_path = @download_file.absolute_file_path

    @download_file.destroy!

    begin
      FileUtils.rm_f(absolute_path)
    rescue StandardError => e
      Rails.logger.error(
        "[DownloadFile delete error] " \
        "#{e.class}: #{e.message}; " \
        "path=#{absolute_path}"
      )
    end

    redirect_to(
      management_screen_download_files_path,
      notice: "ファイル情報を削除しました。",
      status: :see_other
    )
  rescue ActiveRecord::RecordNotDestroyed => e
    Rails.logger.error(
      "[DownloadFile destroy error] " \
      "#{e.class}: #{e.message}"
    )

    redirect_to(
      management_screen_download_files_path,
      alert: "ファイル情報を削除できませんでした。",
      status: :see_other
    )
  end

  private

  def set_download_file
    @download_file = DownloadFile.find(params[:id])
  end

  def download_file_params
    params.require(:download_file).permit(
      :name,
      :filename,
      :pdf_file,
      :volume,
      :download_limit,
      :published,
      :sort_order
    )
  end

  # 仮想属性pdf_fileをDBへ保存しないように除外します。
  def download_file_attributes
    download_file_params.except(:pdf_file)
  end

  def uploaded_pdf
    download_file_params[:pdf_file]
  end

  def valid_pdf?(uploaded_file)
    unless uploaded_file.respond_to?(:tempfile)
      @download_file.errors.add(
        :pdf_file,
        "が正しくありません"
      )
      return false
    end

    if uploaded_file.size.zero?
      @download_file.errors.add(
        :pdf_file,
        "が空です"
      )
      return false
    end

    if uploaded_file.size > MAX_PDF_SIZE
      @download_file.errors.add(
        :pdf_file,
        "は1000MB以下にしてください"
      )
      return false
    end

    extension =
      File.extname(
        uploaded_file.original_filename.to_s
      ).downcase

    unless extension == ".pdf"
      @download_file.errors.add(
        :pdf_file,
        "はPDF形式を選択してください"
      )
      return false
    end

    # Content-Typeだけでは偽装できるため、
    # PDFの先頭文字も確認します。
    uploaded_file.tempfile.rewind
    signature = uploaded_file.tempfile.read(5)
    uploaded_file.tempfile.rewind

    unless signature == "%PDF-"
      @download_file.errors.add(
        :pdf_file,
        "は有効なPDFファイルではありません"
      )
      return false
    end

    true
  end

  def generate_stored_filename
    requested_filename =
      @download_file.filename.presence ||
      uploaded_pdf&.original_filename

    base_name =
      File.basename(
        requested_filename.to_s,
        File.extname(requested_filename.to_s)
      )

    sanitized_base_name =
      base_name
        .encode(
          "UTF-8",
          invalid: :replace,
          undef: :replace,
          replace: "_"
        )
        .gsub(/[^0-9A-Za-z_-]/, "_")
        .gsub(/_+/, "_")
        .delete_prefix("_")
        .delete_suffix("_")
        .truncate(200)

    sanitized_base_name = SecureRandom.uuid if sanitized_base_name.blank?

    "#{sanitized_base_name}.pdf"
  end

  def sanitize_original_filename(filename)
    File.basename(filename.to_s)
        .encode(
          "UTF-8",
          invalid: :replace,
          undef: :replace,
          replace: "_"
        )
        .truncate(255)
  end

end