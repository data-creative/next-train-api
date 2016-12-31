# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161231155135) do

  create_table "agencies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "schedule_id", null: false
    t.string   "url",         null: false
    t.string   "abbrev"
    t.string   "name",        null: false
    t.string   "timezone",    null: false
    t.string   "phone"
    t.string   "lang"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["abbrev"], name: "index_agencies_on_abbrev", using: :btree
    t.index ["name"], name: "index_agencies_on_name", using: :btree
    t.index ["schedule_id", "url"], name: "index_agencies_on_schedule_id_and_url", unique: true, using: :btree
    t.index ["schedule_id"], name: "index_agencies_on_schedule_id", using: :btree
    t.index ["url"], name: "index_agencies_on_url", using: :btree
  end

  create_table "calendars", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "schedule_id", null: false
    t.string   "service_id"
    t.boolean  "monday"
    t.boolean  "tuesday"
    t.boolean  "wednesday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.boolean  "sunday"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["end_date"], name: "index_calendars_on_end_date", using: :btree
    t.index ["schedule_id", "service_id"], name: "index_calendars_on_schedule_id_and_service_id", unique: true, using: :btree
    t.index ["schedule_id"], name: "index_calendars_on_schedule_id", using: :btree
    t.index ["service_id"], name: "index_calendars_on_service_id", using: :btree
    t.index ["start_date"], name: "index_calendars_on_start_date", using: :btree
  end

  create_table "developers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_developers_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_developers_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_developers_on_reset_password_token", unique: true, using: :btree
  end

  create_table "schedules", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "source_url",     null: false
    t.datetime "published_at",   null: false
    t.integer  "content_length"
    t.string   "etag"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["published_at"], name: "index_schedules_on_published_at", using: :btree
    t.index ["source_url", "published_at"], name: "index_schedules_on_source_url_and_published_at", unique: true, using: :btree
    t.index ["source_url"], name: "index_schedules_on_source_url", using: :btree
  end

  create_table "trains", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "origin"
    t.datetime "origin_departure"
    t.string   "destination"
    t.datetime "destination_arrival"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

end
