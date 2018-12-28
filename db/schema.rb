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

ActiveRecord::Schema.define(version: 2018_12_28_185433) do

  create_table "agencies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "schedule_id", null: false
    t.string "url", null: false
    t.string "guid"
    t.string "name"
    t.string "timezone"
    t.string "phone"
    t.string "lang"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guid"], name: "index_agencies_on_guid"
    t.index ["name"], name: "index_agencies_on_name"
    t.index ["schedule_id", "url"], name: "index_agencies_on_schedule_id_and_url", unique: true
    t.index ["schedule_id"], name: "index_agencies_on_schedule_id"
    t.index ["url"], name: "index_agencies_on_url"
  end

  create_table "calendar_dates", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "schedule_id", null: false
    t.string "service_guid"
    t.date "exception_date"
    t.integer "exception_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exception_code"], name: "index_calendar_dates_on_exception_code"
    t.index ["exception_date"], name: "index_calendar_dates_on_exception_date"
    t.index ["schedule_id", "service_guid", "exception_date"], name: "calendar_dates_ck", unique: true
    t.index ["schedule_id"], name: "index_calendar_dates_on_schedule_id"
    t.index ["service_guid"], name: "index_calendar_dates_on_service_guid"
  end

  create_table "calendars", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "schedule_id", null: false
    t.string "service_guid", null: false
    t.boolean "monday"
    t.boolean "tuesday"
    t.boolean "wednesday"
    t.boolean "thursday"
    t.boolean "friday"
    t.boolean "saturday"
    t.boolean "sunday"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_date"], name: "index_calendars_on_end_date"
    t.index ["schedule_id", "service_guid"], name: "index_calendars_on_schedule_id_and_service_guid", unique: true
    t.index ["schedule_id"], name: "index_calendars_on_schedule_id"
    t.index ["service_guid"], name: "index_calendars_on_service_guid"
    t.index ["start_date"], name: "index_calendars_on_start_date"
  end

  create_table "developers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_developers_on_confirmation_token", unique: true
    t.index ["email"], name: "index_developers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_developers_on_reset_password_token", unique: true
  end

  create_table "routes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "schedule_id", null: false
    t.string "guid", null: false
    t.string "agency_guid"
    t.string "short_name"
    t.string "long_name"
    t.text "description"
    t.integer "code"
    t.string "url"
    t.string "color"
    t.string "text_color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_routes_on_code"
    t.index ["guid"], name: "index_routes_on_guid"
    t.index ["schedule_id", "guid"], name: "index_routes_on_schedule_id_and_guid", unique: true
    t.index ["schedule_id"], name: "index_routes_on_schedule_id"
  end

  create_table "schedules", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "source_url", null: false
    t.datetime "published_at", null: false
    t.integer "content_length"
    t.string "etag"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_schedules_on_active"
    t.index ["published_at"], name: "index_schedules_on_published_at"
    t.index ["source_url", "published_at"], name: "index_schedules_on_source_url_and_published_at", unique: true
    t.index ["source_url"], name: "index_schedules_on_source_url"
  end

  create_table "stop_times", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "schedule_id", null: false
    t.string "trip_guid", null: false
    t.string "stop_guid", null: false
    t.integer "stop_sequence"
    t.string "arrival_time"
    t.string "departure_time"
    t.string "headsign"
    t.integer "pickup_code"
    t.integer "dropoff_code"
    t.integer "distance"
    t.integer "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_stop_times_on_code"
    t.index ["schedule_id", "trip_guid", "stop_guid"], name: "index_stop_times_on_schedule_id_and_trip_guid_and_stop_guid", unique: true
    t.index ["schedule_id"], name: "index_stop_times_on_schedule_id"
    t.index ["stop_guid"], name: "index_stop_times_on_stop_guid"
    t.index ["stop_sequence"], name: "index_stop_times_on_stop_sequence"
    t.index ["trip_guid"], name: "index_stop_times_on_trip_guid"
  end

  create_table "stops", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "schedule_id", null: false
    t.string "guid", null: false
    t.string "short_name"
    t.string "name"
    t.string "description"
    t.decimal "latitude", precision: 10, scale: 8
    t.decimal "longitude", precision: 11, scale: 8
    t.string "zone_guid"
    t.string "url"
    t.integer "location_code"
    t.string "parent_guid"
    t.string "timezone"
    t.integer "wheelchair_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guid"], name: "index_stops_on_guid"
    t.index ["location_code"], name: "index_stops_on_location_code"
    t.index ["parent_guid"], name: "index_stops_on_parent_guid"
    t.index ["schedule_id", "guid"], name: "index_stops_on_schedule_id_and_guid", unique: true
    t.index ["schedule_id"], name: "index_stops_on_schedule_id"
    t.index ["wheelchair_code"], name: "index_stops_on_wheelchair_code"
    t.index ["zone_guid"], name: "index_stops_on_zone_guid"
  end

  create_table "trips", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "schedule_id", null: false
    t.string "guid", null: false
    t.string "route_guid"
    t.string "service_guid"
    t.string "headsign"
    t.string "short_name"
    t.integer "direction_code"
    t.string "block_guid"
    t.string "shape_guid"
    t.integer "wheelchair_code"
    t.integer "bicycle_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direction_code"], name: "index_trips_on_direction_code"
    t.index ["guid"], name: "index_trips_on_guid"
    t.index ["schedule_id", "guid"], name: "index_trips_on_schedule_id_and_guid", unique: true
    t.index ["schedule_id"], name: "index_trips_on_schedule_id"
  end

end
