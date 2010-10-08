# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100920012822) do

  create_table "emails", :force => true do |t|
    t.integer  "source_id",  :null => false
    t.text     "title",      :null => false
    t.text     "body",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "emails", ["source_id"], :name => "source_id"

  create_table "entries", :force => true do |t|
    t.integer  "source_id",                          :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.datetime "sent_at",                            :null => false
    t.string   "symbol",       :limit => 256,        :null => false
    t.integer  "message_type",                       :null => false
    t.string   "url",          :limit => 512
    t.string   "guid",         :limit => 512,        :null => false
    t.text     "subject"
    t.text     "body",         :limit => 2147483647
  end

  create_table "quotes", :force => true do |t|
    t.string   "symbol",                                     :null => false
    t.string   "exchange"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.datetime "market_time",                                :null => false
    t.decimal  "last_price",  :precision => 10, :scale => 6, :null => false
  end

  create_table "sources", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "address",    :null => false
    t.float    "weight",     :null => false
    t.string   "twitter"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tweets", :force => true do |t|
    t.integer  "source_id",  :null => false
    t.text     "text",       :null => false
    t.datetime "updated_at", :null => false
    t.datetime "created_at", :null => false
  end

  add_index "tweets", ["source_id"], :name => "source_id"

  create_table "users", :force => true do |t|
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
    t.boolean  "profile_background_tiled"
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
