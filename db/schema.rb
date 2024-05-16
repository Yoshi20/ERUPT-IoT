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

ActiveRecord::Schema.define(version: 2024_05_16_075820) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abo_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "abo_types_members", force: :cascade do |t|
    t.bigint "abo_type_id", null: false
    t.bigint "member_id", null: false
    t.datetime "expiration_date", precision: 6, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["abo_type_id", "member_id"], name: "index_abo_types_members_on_abo_type_id_and_member_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "device_types", force: :cascade do |t|
    t.string "name", null: false
    t.integer "number_of_buttons"
  end

  create_table "devices", force: :cascade do |t|
    t.string "name", null: false
    t.string "dev_eui", null: false
    t.string "app_eui"
    t.string "app_key"
    t.string "hw_version"
    t.string "fw_version"
    t.integer "battery"
    t.datetime "last_time_seen"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "device_type_id"
    t.bigint "user_id"
    t.index ["device_type_id"], name: "index_devices_on_device_type_id"
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer "overall_rating", null: false
    t.integer "service_rating"
    t.integer "ambient_rating"
    t.string "how_often_do_you_visit"
    t.string "what_to_improve"
    t.string "what_to_keep"
    t.integer "console_rating"
    t.string "console_comment"
    t.integer "pc_rating"
    t.string "pc_comment"
    t.integer "karaoke_rating"
    t.string "karaoke_comment"
    t.integer "board_game_rating"
    t.string "board_game_comment"
    t.integer "offer_rating"
    t.string "offer_comment"
    t.boolean "read", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "members", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", null: false
    t.datetime "birthdate"
    t.string "mobile_number"
    t.string "gender"
    t.string "canton"
    t.text "comment"
    t.boolean "wants_newsletter_emails"
    t.boolean "wants_event_emails"
    t.string "card_id"
    t.float "magma_coins"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ggleap_uuid"
    t.boolean "locked", default: false
    t.boolean "is_hourly_worker", default: false
  end

  create_table "orders", force: :cascade do |t|
    t.string "title"
    t.string "text"
    t.string "data"
    t.boolean "acknowledged", default: false
    t.string "acknowledged_by"
    t.datetime "acknowledged_at"
    t.bigint "device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_orders_on_device_id"
  end

  create_table "scan_events", force: :cascade do |t|
    t.bigint "member_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "post_body"
    t.string "card_id"
    t.string "abo_types"
    t.boolean "hourly_worker_in", default: false
    t.boolean "hourly_worker_out", default: false
    t.bigint "hourly_worker_delta_time"
    t.bigint "hourly_worker_monthly_time"
    t.datetime "hourly_worker_time_stamp", precision: 6
    t.boolean "hourly_worker_has_removed_30_min", default: false
    t.boolean "hourly_worker_was_automatically_clocked_out", default: false
    t.index ["member_id"], name: "index_scan_events_on_member_id"
  end

  create_table "time_stamps", force: :cascade do |t|
    t.datetime "value"
    t.boolean "is_in", default: false
    t.boolean "is_out", default: false
    t.bigint "sick_time"
    t.bigint "paid_leave_time"
    t.bigint "extra_time"
    t.bigint "delta_time"
    t.bigint "monthly_time"
    t.bigint "removed_break_time", default: 0
    t.bigint "added_night_time", default: 0
    t.boolean "was_automatically_clocked_out", default: false
    t.boolean "was_manually_edited", default: false
    t.boolean "was_manually_validated", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "scan_event_id"
    t.bigint "user_id"
    t.index ["scan_event_id"], name: "index_time_stamps_on_scan_event_id"
    t.index ["user_id"], name: "index_time_stamps_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username"
    t.boolean "is_admin"
    t.string "full_name"
    t.string "mobile_number"
    t.boolean "is_hourly_worker", default: false
    t.bigint "member_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["member_id"], name: "index_users_on_member_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "wifi_displays", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
  end

  add_foreign_key "devices", "device_types"
  add_foreign_key "devices", "users"
  add_foreign_key "orders", "devices"
  add_foreign_key "scan_events", "members"
  add_foreign_key "time_stamps", "scan_events"
  add_foreign_key "time_stamps", "users"
  add_foreign_key "users", "members"
end
