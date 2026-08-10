# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_06_10_080845) do
  create_table "contacts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "subject", limit: 50, null: false
    t.string "email", null: false
    t.text "message", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "trash", default: false, null: false
    t.boolean "unread", default: false, null: false
    t.string "email_hash", null: false
    t.datetime "reply_time", precision: nil
    t.index ["email"], name: "index_contacts_on_email"
  end

  create_table "download_files", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "filename", null: false
    t.string "path", limit: 500, null: false
    t.integer "volume", limit: 1, null: false, unsigned: true
    t.bigint "file_size", unsigned: true
    t.string "content_type", limit: 100
    t.integer "download_limit", default: 0, null: false, unsigned: true
    t.integer "download_count", default: 0, null: false, unsigned: true
    t.boolean "published", default: false, null: false
    t.integer "sort_order", default: 0, null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" }, null: false
    t.index ["path"], name: "uk_download_files_path", unique: true
  end

  create_table "download_logs", id: { type: :bigint, unsigned: true }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "download_file_id", null: false, unsigned: true
    t.bigint "regist_id"
    t.datetime "downloaded_at", precision: nil, null: false
    t.string "ip_address", limit: 45
    t.text "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["download_file_id"], name: "index_download_logs_on_download_file_id"
    t.index ["downloaded_at"], name: "index_download_logs_on_downloaded_at"
    t.index ["regist_id"], name: "index_download_logs_on_regist_id"
  end

  create_table "regists", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "email", null: false
    t.string "token", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email_hash", null: false
    t.integer "download_count", default: 0
    t.boolean "subscribed", default: false, null: false
    t.datetime "email_sent_01", precision: nil
    t.datetime "email_sent_02", precision: nil
    t.boolean "unread", default: false, null: false
    t.boolean "trash", default: false, null: false
    t.integer "second_download_count", default: 0
    t.string "second_token", limit: 50, null: false
    t.index ["email"], name: "index_regists_on_email", unique: true
    t.index ["email_hash"], name: "index_regists_on_email_hash", unique: true
  end

  create_table "replies", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 50
    t.string "subject", limit: 50
    t.string "email_hash", limit: 64
    t.text "message"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" }
    t.integer "contact_id"
    t.boolean "unread", default: false
    t.integer "regist_id"
    t.boolean "trash", default: false, null: false
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 50
    t.string "email", null: false
    t.string "email_hash", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" }
    t.string "firebase_uid", limit: 128
    t.index ["email_hash"], name: "email_hash", unique: true
    t.index ["firebase_uid"], name: "uk_users_firebase_uid", unique: true
  end

  add_foreign_key "download_logs", "download_files", name: "fk_download_logs_download_file"
  add_foreign_key "download_logs", "regists", name: "fk_download_logs_regist"
end
