# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140328032618) do

  create_table "meetings", primary_key: "open_time", force: true do |t|
    t.time     "enter_time"
    t.integer  "reserved_table"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "twitter_users", force: true do |t|
    t.string   "username",      limit: 20, null: false
    t.string   "screen_name",   limit: 15, null: false
    t.integer  "open_time",                null: false
    t.string   "icon_src",                 null: false
    t.string   "access_token",             null: false
    t.string   "access_secret",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time     "entry_time"
    t.boolean  "is_student"
  end

  create_table "user_round_results", force: true do |t|
    t.integer  "user_id",                null: false
    t.integer  "open_time",              null: false
    t.integer  "round_id",               null: false
    t.integer  "seat",                   null: false
    t.integer  "rank",                   null: false
    t.integer  "score",                  null: false
    t.integer  "plus_minus",             null: false
    t.integer  "yakuman",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "tweeted"
  end

  create_table "users", force: true do |t|
    t.string   "twitter_id"
    t.string   "login"
    t.string   "access_token"
    t.string   "access_secret"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "location"
    t.string   "description"
    t.string   "profile_image_url"
    t.string   "url"
    t.boolean  "protected"
    t.string   "profile_background_color"
    t.string   "profile_sidebar_fill_color"
    t.string   "profile_link_color"
    t.string   "profile_sidebar_border_color"
    t.string   "profile_text_color"
    t.string   "profile_background_image_url"
    t.boolean  "profile_background_tile"
    t.integer  "friends_count"
    t.integer  "statuses_count"
    t.integer  "followers_count"
    t.integer  "favourites_count"
    t.integer  "utc_offset"
    t.string   "time_zone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
