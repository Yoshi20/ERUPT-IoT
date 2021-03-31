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

ActiveRecord::Schema.define(version: 2021_03_31_141225) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abo_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "abo_types_members", id: false, force: :cascade do |t|
    t.bigint "abo_type_id", null: false
    t.bigint "member_id", null: false
    t.index ["abo_type_id", "member_id"], name: "index_abo_types_members_on_abo_type_id_and_member_id"
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
  end

  create_table "members", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.datetime "birthdate"
    t.string "mobile_number"
    t.string "gender"
    t.string "canton"
    t.text "comment"
    t.boolean "wants_newsletter_emails"
    t.boolean "wants_event_emails"
    t.string "card_id", null: false
    t.float "magma_coins"
    t.datetime "expiration_date"
    t.integer "number_of_scans"
    t.boolean "active", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "scan_events", force: :cascade do |t|
    t.bigint "member_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "devices", "device_types"
  add_foreign_key "devices", "users"
  add_foreign_key "scan_events", "members"
end
