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

ActiveRecord::Schema.define(version: 20161231052921) do

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

  create_table "trains", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "origin"
    t.datetime "origin_departure"
    t.string   "destination"
    t.datetime "destination_arrival"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "transit_schedules", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "source_url",     null: false
    t.datetime "published_at",   null: false
    t.integer  "content_length"
    t.string   "etag"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["published_at"], name: "index_transit_schedules_on_published_at", using: :btree
    t.index ["source_url", "published_at"], name: "index_transit_schedules_on_source_url_and_published_at", unique: true, using: :btree
    t.index ["source_url"], name: "index_transit_schedules_on_source_url", using: :btree
  end

end
