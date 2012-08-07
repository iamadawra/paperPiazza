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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120807090557) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "time"
    t.string   "action"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "assignment_entries", :force => true do |t|
    t.integer  "number"
    t.integer  "assignment_id"
    t.integer  "question_id"
    t.decimal  "points",         :precision => 10, :scale => 4, :default => 0.0
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.integer  "resubmit_delay"
  end

  create_table "assignments", :force => true do |t|
    t.string   "title"
    t.datetime "release_date"
    t.datetime "due_date"
    t.decimal  "total_points",   :precision => 10, :scale => 4, :default => 0.0
    t.integer  "course_id"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.boolean  "feedback",                                      :default => false
    t.integer  "resubmit_delay"
  end

  create_table "categories", :force => true do |t|
    t.string   "title"
    t.boolean  "state",      :default => true
    t.integer  "position",   :default => 0
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.string   "body",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "comments", ["user_id", "course_id"], :name => "index_comments_on_user_id_and_course_id"

  create_table "course_memberships", :force => true do |t|
    t.integer  "course_id",               :null => false
    t.integer  "user_id",                 :null => false
    t.integer  "role",       :limit => 1, :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "course_memberships", ["course_id", "user_id"], :name => "index_course_memberships_on_course_id_and_user_id", :unique => true
  add_index "course_memberships", ["course_id"], :name => "index_course_memberships_on_course_id"
  add_index "course_memberships", ["user_id"], :name => "index_course_memberships_on_user_id"

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.string   "shortname"
    t.text     "description"
    t.integer  "year"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "rating"
    t.string   "conference"
  end

  create_table "forums", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.boolean  "state",        :default => true
    t.integer  "topics_count", :default => 0
    t.integer  "posts_count",  :default => 0
    t.integer  "position",     :default => 0
    t.integer  "category_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.boolean  "approved"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "in_lecture_questions", :force => true do |t|
    t.integer  "lecture_id",                 :null => false
    t.integer  "question_id",                :null => false
    t.integer  "hours",       :default => 0, :null => false
    t.integer  "minutes",     :default => 0, :null => false
    t.integer  "seconds",     :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "lectures", :force => true do |t|
    t.string   "title"
    t.string   "video_url"
    t.string   "slides_url"
    t.integer  "number"
    t.datetime "release_date"
    t.integer  "course_id"
    t.integer  "video_duration"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "pfeed_deliveries", :force => true do |t|
    t.integer  "pfeed_receiver_id"
    t.string   "pfeed_receiver_type"
    t.integer  "pfeed_item_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "pfeed_items", :force => true do |t|
    t.string   "type"
    t.integer  "originator_id"
    t.string   "originator_type"
    t.integer  "participant_id"
    t.string   "participant_type"
    t.text     "data"
    t.datetime "expiry"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "posts", :force => true do |t|
    t.text     "body"
    t.integer  "forum_id"
    t.integer  "topic_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "question_submissions", :force => true do |t|
    t.boolean  "graded"
    t.decimal  "score",       :precision => 10, :scale => 4
    t.text     "answer"
    t.integer  "question_id"
    t.integer  "user_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "questions", :force => true do |t|
    t.string   "type",                :limit => 100
    t.text     "text"
    t.text     "choices"
    t.text     "answers"
    t.text     "explanations"
    t.integer  "parent_id"
    t.integer  "child_index"
    t.decimal  "weight",                             :precision => 10, :scale => 4, :default => 1.0
    t.text     "json"
    t.text     "raw_source"
    t.string   "raw_source_format"
    t.text     "javascript_includes"
    t.text     "parameters"
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
    t.integer  "course_id"
    t.string   "title"
  end

  add_index "questions", ["parent_id"], :name => "index_questions_on_parent_id"

  create_table "rates", :force => true do |t|
    t.integer  "rater_id"
    t.integer  "rateable_id"
    t.string   "rateable_type"
    t.integer  "stars",         :null => false
    t.string   "dimension"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "rates", ["rateable_id", "rateable_type"], :name => "index_rates_on_rateable_id_and_rateable_type"
  add_index "rates", ["rater_id"], :name => "index_rates_on_rater_id"

  create_table "rubric_items", :force => true do |t|
    t.text     "title"
    t.text     "description"
    t.decimal  "weight",      :precision => 10, :scale => 4
    t.integer  "question_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.integer  "hits",        :default => 0
    t.boolean  "sticky",      :default => false
    t.boolean  "locked",      :default => false
    t.integer  "posts_count"
    t.integer  "forum_id"
    t.integer  "user_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "remember_token"
    t.string   "perishable_token"
    t.datetime "password_reset_sent_at"
    t.boolean  "admin",                  :default => false, :null => false
    t.integer  "owner_id"
    t.integer  "topics_count",           :default => 0
    t.integer  "posts_count",            :default => 0
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
